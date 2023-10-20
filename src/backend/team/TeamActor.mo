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
import Nat "mo:base/Nat";
import Error "mo:base/Error";
import Text "mo:base/Text";
import Iter "mo:base/Iter";
import None "mo:base/None";
import { ic } "mo:ic";
import Stadium "../Stadium";
import IterTools "mo:itertools/Iter";
import Types "mo:icrc1/ICRC1/Types";

shared (install) actor class TeamActor(
  initLeagueId : Principal,
  ledgerId : Principal,
) : async Team.TeamActor = this {

  type PlayerWithId = Player.PlayerWithId;
  type MatchOptionsCallback = Team.MatchOptionsCallback;
  type GetMatchOptionsResult = Team.GetMatchOptionsResult;
  type MatchOptions = Team.MatchOptions;
  type MatchOptionsVote = Team.MatchOptionsVote;
  type VoteForMatchOptionsResult = Team.VoteForMatchOptionsResult;
  type OfferingWithId = Stadium.OfferingWithId;
  type SpecialRuleWithId = Stadium.SpecialRuleWithId;
  type GetCyclesResult = Team.GetCyclesResult;
  type StadiumMatchId = Text; // Stadium Principal Text # _ # Match Id Text

  stable var leagueId = initLeagueId;
  var matchOptions : Trie.Trie<StadiumMatchId, Trie.Trie<Principal, MatchOptionsVote>> = Trie.empty();
  var ledger : Types.TokenInterface = actor (Principal.toText(ledgerId));

  public composite query func getPlayers() : async [PlayerWithId] {
    let teamId = Principal.fromActor(this);
    await PlayerLedgerActor.getTeamPlayers(?teamId);
  };

  public shared ({ caller }) func voteForMatchOptions(
    stadiumId : Principal,
    matchId : Nat32,
    vote : MatchOptionsVote,
  ) : async VoteForMatchOptionsResult {
    let isOwner = await isTeamOwner(caller);
    if (not isOwner) {
      return #notAuthorized;
    };
    let stadiumActor = actor (Principal.toText(stadiumId)) : Stadium.StadiumActor;
    let match = try {
      let ?match = await stadiumActor.getMatch(matchId) else return #matchNotFound;
      match;
    } catch (err) {
      return #stadiumNotFound;
    };

    let teamId = Principal.fromActor(this);
    if (match.teams.0.id != teamId and match.teams.1.id != teamId) {
      return #teamNotInMatch;
    };

    let errors = Buffer.Buffer<Text>(0);
    let offeringExists = IterTools.any(match.offerings.vals(), func(o : OfferingWithId) : Bool = o.id == vote.offeringId);
    if (not offeringExists) {
      errors.add("Invalid offering: " # Nat32.toText(vote.offeringId));
    };
    let specialRuleExists = IterTools.any(match.specialRules.vals(), func(r : SpecialRuleWithId) : Bool = r.id == vote.specialRuleId);
    if (not specialRuleExists) {
      errors.add("Invalid special rule: " # Nat32.toText(vote.specialRuleId));
    };
    if (errors.size() > 0) {
      return #invalid(Buffer.toArray(errors));
    };

    let stadiumMatchId = buildStadiumMatchId(stadiumId, matchId);
    let matchKey = {
      key = stadiumMatchId;
      hash = Text.hash(stadiumMatchId);
    };
    let matchVotes : Trie.Trie<Principal, MatchOptionsVote> = switch (Trie.get(matchOptions, matchKey, Text.equal)) {
      case (null) Trie.empty();
      case (?o) o;
    };
    let voteKey = {
      key = caller;
      hash = Principal.hash(caller);
    };
    switch (Trie.put(matchVotes, voteKey, Principal.equal, vote)) {
      case ((_, ?existingVote)) #alreadyVoted;
      case ((newMatchVotes, null)) {
        // Add vote
        let (newOptions, _) = Trie.put(
          matchOptions,
          matchKey,
          Text.equal,
          matchVotes,
        );
        matchOptions := newOptions;
        #ok;
      };
    };
  };

  public shared query ({ caller }) func getMatchOptions(
    stadiumId : Principal,
    matchId : Nat32,
  ) : async GetMatchOptionsResult {
    if (caller != stadiumId or caller != leagueId) {
      return #notAuthorized;
    };
    let stadiumMatchId = buildStadiumMatchId(stadiumId, matchId);
    let matchKey = {
      key = stadiumMatchId;
      hash = Text.hash(stadiumMatchId);
    };
    switch (Trie.get(matchOptions, matchKey, Text.equal)) {
      case (null) #noVotes;
      case (?o) {
        let ?(offeringId, specialRuleVotes) = calculateVotes(o) else return #noVotes;
        #ok({
          offeringId = offeringId;
          specialRuleVotes = specialRuleVotes;
        });
      };
    };
  };

  public shared ({ caller }) func getCycles() : async GetCyclesResult {
    if (caller != leagueId) {
      return #notAuthorized;
    };
    let canisterStatus = await ic.canister_status({
      canister_id = Principal.fromActor(this);
    });
    return #ok(canisterStatus.cycles);
  };

  public shared ({ caller }) func getLedgerId() : async Principal {
    return ledgerId;
  };

  private func calculateVotes(matchVotes : Trie.Trie<Principal, MatchOptionsVote>) : ?(Nat32, [(Nat32, Nat)]) {
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
    let specialRuleVoteArray = Trie.iter(specialRuleVotes)
    |> Iter.toArray(_);
    switch (winningOfferingId) {
      case (null) null;
      case (?offeringId) ?(offeringId.0, specialRuleVoteArray);
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

  private func buildStadiumMatchId(stadiumId : Principal, matchId : Nat32) : Text {
    Principal.toText(stadiumId) # "_" # Nat32.toText(matchId);
  };

  private func isTeamOwner(caller : Principal) : async Bool {
    // TODO change to staking
    let tokenCount = await ledger.icrc1_balance_of({
      owner = caller;
      subaccount = null;
    });
    return tokenCount > 0;
  };

};
