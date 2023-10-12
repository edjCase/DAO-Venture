import Player "../Player";
import Principal "mo:base/Principal";
import Team "../Team";
import Trie "mo:base/Trie";
import Hash "mo:base/Hash";
import Nat32 "mo:base/Nat32";
import Debug "mo:base/Debug";
import Prelude "mo:base/Prelude";
import TeamUtil "TeamUtil";
import TrieSet "mo:base/TrieSet";
import PlayerLedgerActor "canister:playerLedger";
import Array "mo:base/Array";
import Buffer "mo:base/Buffer";
import { ic } "mo:ic";
import Stadium "../Stadium";

shared (install) actor class TeamActor(leagueId : Principal, ownerId : Principal) : async Team.TeamActor = this {
  type PlayerWithId = Player.PlayerWithId;
  type MatchVote = {
    offeringId : Nat32;
    specialRuleId : Nat32;
  };
  public type MatchOptions = {
    offeringId : Nat32;
    specialRuleId : Nat32;
  };
  public type VoteResult = {
    #stadiumNotFound;
    #matchNotFound;
    #teamNotInMatch;
    #invalid : [Text];
    #alreadyVoted;
    #ok;
  };

  // Stadium => Match => User => Vote
  stable var votes = Trie.empty<Principal, Trie.Trie<Nat32, Trie.Trie<Principal, MatchVote>>>();

  public composite query func getPlayers() : async [PlayerWithId] {
    let teamId = Principal.fromActor(this);
    await PlayerLedgerActor.getTeamPlayers(?teamId);
  };

  public shared query ({ caller }) func getMatchOptions(matchId : Nat32) : async ?Stadium.MatchOptions {
    let teamId = Principal.fromActor(this);
    let stadiumKey = {
      key = caller;
      hash = Principal.hash(caller);
    };
    let ?stadiumVotes = Trie.get(votes, stadiumKey, Principal.equal) else return null;
    let matchKey = {
      key = matchId;
      hash = matchId;
    };
    let ?matchVotes = Trie.get(stadiumVotes, matchKey, Nat32.equal) else return null;
    let ?(offeringId, specialRuleVotes) = calculateVotes(matchVotes) else return null;
    ?{
      offeringId = offeringId;
      specialRuleVotes = specialRuleVotes;
    };
  };

  private func calculateVotes(matchVotes : Trie.Trie<Principal, MatchVote>) : ?(Nat32, Trie.Trie<Nat32, Nat>) {
    var offeringVotes = Trie.empty<Nat32, Nat>();
    var specialRuleVotes = Trie.empty<Nat32, Nat>();
    for ((userId, vote) in Trie.iter(matchVotes)) {
      // Offering
      let userVotingPower = 1; // TODO
      offeringVotes := addVotes(offeringVotes, vote.offeringId, userVotingPower);

      specialRuleVotes := addVotes(offeringVotes, vote.specialRuleId, userVotingPower);
    };
    var winningOfferingId : ?(Nat32, Nat) = null;
    for ((offeringId, votes) in Trie.iter(offeringVotes)) {
      switch (winningOfferingId) {
        case (null) winningOfferingId := ?(offeringId, votes);
        case (?o) {
          if (o.1 < votes) {
            winningOfferingId := ?(offeringId, votes);
          };
          // TODO what to do if there is a tie?
        };
      };
    };
    switch (winningOfferingId) {
      case (null) null;
      case (?offeringId) ?(offeringId.0, specialRuleVotes);
    };

  };

  private func addVotes(votes : Trie.Trie<Nat32, Nat>, choice : Nat32, value : Nat) : Trie.Trie<Nat32, Nat> {
    let key = {
      key = choice;
      hash = choice;
    };
    let currentVotes = switch (Trie.get(votes, key, Nat32.equal)) {
      case (?v) v;
      case (null) 0;
    };
    let (newVotes, _) = Trie.put(votes, key, Nat32.equal, currentVotes + value);
    newVotes;
  };

  public shared ({ caller }) func getOwner() : async Principal {
    return ownerId;
  };

  public shared ({ caller }) func getCycles() : async Nat {
    assertOwner(caller);
    let canisterStatus = await ic.canister_status({
      canister_id = Principal.fromActor(this);
    });
    return canisterStatus.cycles;
  };

  public shared ({ caller }) func voteForMatchOptions(
    stadiumId : Principal,
    matchId : Nat32,
    options : MatchOptions,
  ) : async VoteResult {
    assertOwner(caller);
    let stadiumActor = actor (Principal.toText(stadiumId)) : Stadium.StadiumActor;
    let ?match = await stadiumActor.getMatch(matchId) else return #matchNotFound;

    let teamId = Principal.fromActor(this);
    if (match.teams.0.id != teamId and match.teams.1.id != teamId) {
      return #teamNotInMatch;
    };

    let errors = Buffer.Buffer<Text>(0);
    if (match.offerings.size() <= Nat32.toNat(options.offeringId)) {
      errors.add("Invalid offering: " # Nat32.toText(options.offeringId));
    };
    if (match.specialRules.size() <= Nat32.toNat(options.specialRuleId)) {
      errors.add("Invalid special rule: " # Nat32.toText(options.specialRuleId));
    };
    if (errors.size() > 0) {
      return #invalid(Buffer.toArray(errors));
    };

    let stadiumKey = {
      key = stadiumId;
      hash = Principal.hash(stadiumId);
    };
    let stadiumVotes = switch (Trie.get(votes, stadiumKey, Principal.equal)) {
      case (?s) s;
      case (null) Trie.empty<Nat32, Trie.Trie<Principal, MatchVote>>();
    };
    let matchKey = {
      key = matchId;
      hash = matchId;
    };
    let matchVotes = switch (Trie.get(stadiumVotes, matchKey, Nat32.equal)) {
      case (?m) m;
      case (null) Trie.empty<Principal, MatchVote>();
    };
    let userKey = {
      key = caller;
      hash = Principal.hash(caller);
    };
    if (Trie.get(matchVotes, userKey, Principal.equal) != null) {
      return #alreadyVoted;
    };
    let matchVote = {
      offeringId = options.offeringId;
      specialRuleId = options.specialRuleId;
    };
    let (newMatchVotes, _) = Trie.put(matchVotes, userKey, Principal.equal, matchVote);
    let (newStadiumVotes, _) = Trie.put(stadiumVotes, matchKey, Nat32.equal, newMatchVotes);
    let (newVotes, _) = Trie.put(votes, stadiumKey, Principal.equal, newStadiumVotes);
    votes := newVotes;
    #ok;
  };

  private func assertOwner(caller : Principal) {
    if (caller != ownerId) {
      Debug.trap("Caller is not the owner of the team");
    };
  };

};
