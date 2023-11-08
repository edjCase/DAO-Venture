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
  leagueId : Principal,
  stadiumId : Principal,
  divisionId : Principal,
  ledgerId : Principal,
) : async Team.TeamActor = this {

  type PlayerWithId = Player.PlayerWithId;
  type MatchOptionsCallback = Team.MatchOptionsCallback;
  type MatchOptions = Stadium.MatchOptions;
  type Offering = Stadium.Offering;
  type MatchAura = Stadium.MatchAura;
  type GetCyclesResult = Team.GetCyclesResult;
  type StadiumMatchId = Text; // Stadium Principal Text # _ # Match Id Text
  type PlayerId = Player.PlayerId;

  stable var matchGroupVotes : Trie.Trie<Nat32, Trie.Trie<Principal, Team.MatchGroupVote>> = Trie.empty();
  let ledger : Types.TokenInterface = actor (Principal.toText(ledgerId));

  public composite query func getPlayers() : async [PlayerWithId] {
    let teamId = Principal.fromActor(this);
    await PlayerLedgerActor.getTeamPlayers(?teamId);
  };

  public shared ({ caller }) func voteOnMatchGroup(request : Team.VoteOnMatchGroupRequest) : async Team.VoteOnMatchGroupResult {
    let isOwner = await isTeamOwner(caller);
    if (not isOwner) {
      return #notAuthorized;
    };
    let stadiumActor = actor (Principal.toText(stadiumId)) : Stadium.StadiumActor;
    let matchGroup = try {
      let ?matchGroup = await stadiumActor.getMatchGroup(request.matchGroupId) else return #matchGroupNotFound;
      matchGroup;
    } catch (err) {
      return #matchGroupFetchError(Error.message(err));
    };
    let teamId = Principal.fromActor(this);
    let match = switch (matchGroup.state) {
      case (#notStarted(ns)) {
        let ?match = matchGroup.matches
        |> Array.find(
          _,
          func(m : Stadium.Match) : Bool = m.team1.id == teamId or m.team2.id == teamId,
        ) else return #teamNotInMatchGroup;
        match;
      };
      case (#inProgress(ip)) return #alreadyStarted;
      case (#completed(c)) return #alreadyStarted;
    };

    let errors = Buffer.Buffer<Team.InvalidVoteError>(0);
    let offeringExists = IterTools.any(match.offerings.vals(), func(o : Offering) : Bool = o == request.offering);
    if (not offeringExists) {
      errors.add(#invalidOffering(request.offering));
    };
    let teamPlayers : [Stadium.MatchPlayer] = if (match.team1.id == teamId) {
      match.team1.players;
    } else if (match.team2.id == teamId) {
      match.team2.players;
    } else {
      return #teamNotInMatchGroup;
    };
    let championExists = IterTools.any(teamPlayers.vals(), func(p : Stadium.MatchPlayer) : Bool = p.id == request.championId);
    if (not championExists) {
      errors.add(#invalidChampionId(request.championId));
    };
    if (errors.size() > 0) {
      return #invalid(Buffer.toArray(errors));
    };

    let matchGroupKey = {
      key = request.matchGroupId;
      hash = request.matchGroupId;
    };
    let matchGroupVoteData = switch (Trie.get(matchGroupVotes, matchGroupKey, Nat32.equal)) {
      case (null) Trie.empty();
      case (?o) o;
    };
    let voteKey = {
      key = caller;
      hash = Principal.hash(caller);
    };
    switch (Trie.put(matchGroupVoteData, voteKey, Principal.equal, request)) {
      case ((_, ?existingVote)) #alreadyVoted;
      case ((newMatchVotes, null)) {
        // Add vote
        let (newMatchGroupVotes, _) = Trie.put(
          matchGroupVotes,
          matchGroupKey,
          Nat32.equal,
          newMatchVotes,
        );
        matchGroupVotes := newMatchGroupVotes;
        #ok;
      };
    };
  };

  public shared query ({ caller }) func getMatchGroupVote(matchGroupId : Nat32) : async Team.GetMatchGroupVoteResult {
    if (caller != stadiumId) {
      return #notAuthorized;
    };
    let matchGroupKey = {
      key = matchGroupId;
      hash = matchGroupId;
    };
    switch (Trie.get(matchGroupVotes, matchGroupKey, Nat32.equal)) {
      case (null) #noVotes;
      case (?o) {
        let ?{ offering; championId } = calculateVotes(o) else return #noVotes;
        #ok({
          offering = offering;
          championId = championId;
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

  private func calculateVotes(matchVotes : Trie.Trie<Principal, Team.MatchGroupVote>) : ?{
    offering : Offering;
    championId : PlayerId;
  } {
    var offeringVotes = Trie.empty<Offering, Nat>();
    var championVotes = Trie.empty<PlayerId, Nat>();
    for ((userId, vote) in Trie.iter(matchVotes)) {
      // Offering
      let userVotingPower = 1; // TODO
      let offeringKey = {
        key = vote.offering;
        hash = Stadium.hashOffering(vote.offering);
      };
      offeringVotes := addVotes(offeringVotes, offeringKey, Stadium.equalOffering, userVotingPower);
      let championKey = {
        key = vote.championId;
        hash = vote.championId;
      };
      championVotes := addVotes(championVotes, championKey, Nat32.equal, userVotingPower);
    };
    let ?winningOffering = calculateVote(offeringVotes) else return null;
    let ?winningChampionId = calculateVote(championVotes) else return null;
    ?{
      offering = winningOffering;
      championId = winningChampionId;
    };
  };

  private func calculateVote<T>(votes : Trie.Trie<T, Nat>) : ?T {
    var winningVote : ?(T, Nat) = null;
    for ((choice, votes) in Trie.iter(votes)) {
      switch (winningVote) {
        case (null) winningVote := ?(choice, votes);
        case (?o) {
          if (o.1 < votes) {
            winningVote := ?(choice, votes);
          };
          // TODO what to do if there is a tie?
        };
      };
    };
    switch (winningVote) {
      case (null) null;
      case (?offering) ?offering.0;
    };
  };

  private func addVotes<T>(votes : Trie.Trie<T, Nat>, key : Trie.Key<T>, equal : (T, T) -> Bool, value : Nat) : Trie.Trie<T, Nat> {

    let currentVotes = switch (Trie.get(votes, key, equal)) {
      case (?v) v;
      case (null) 0;
    };
    let (newVotes, _) = Trie.put(votes, key, equal, currentVotes + value);
    newVotes;
  };
  private func isTeamOwner(caller : Principal) : async Bool {
    // TODO change to staking
    // TODO re-enable
    // let tokenCount = await ledger.icrc1_balance_of({
    //   owner = Principal.fromActor(this);
    //   subaccount = ?Principal.toBlob(caller);
    // });
    // return tokenCount > 0;
    return true;
  };

};
