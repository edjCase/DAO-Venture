import Player "../models/Player";
import Principal "mo:base/Principal";
import Team "../models/Team";
import Trie "mo:base/Trie";
import Hash "mo:base/Hash";
import Nat32 "mo:base/Nat32";
import Debug "mo:base/Debug";
import Prelude "mo:base/Prelude";
import TrieSet "mo:base/TrieSet";
import Array "mo:base/Array";
import Buffer "mo:base/Buffer";
import Nat "mo:base/Nat";
import Error "mo:base/Error";
import Text "mo:base/Text";
import Iter "mo:base/Iter";
import None "mo:base/None";
import Nat8 "mo:base/Nat8";
import { ic } "mo:ic";
import StadiumTypes "../stadium/Types";
import PlayersTypes "../players/Types";
import IterTools "mo:itertools/Iter";
import LeagueTypes "../league/Types";
import Types "Types";
import MatchAura "../models/MatchAura";
import Season "../models/Season";
import Util "../Util";
import Scenario "../models/Scenario";

shared (install) actor class TeamActor(
  leagueId : Principal,
  playersActorId : Principal,
) : async Types.TeamActor = this {

  type MatchAura = MatchAura.MatchAura;
  type GetCyclesResult = Types.GetCyclesResult;
  type PlayerId = Player.PlayerId;

  stable var matchGroupVotes : Trie.Trie<Nat, Trie.Trie<Principal, Types.MatchGroupVote>> = Trie.empty();

  public composite query func getPlayers() : async [Player.PlayerWithId] {
    let teamId = Principal.fromActor(this);
    let playersActor = actor (Principal.toText(playersActorId)) : PlayersTypes.PlayerActor;
    await playersActor.getTeamPlayers(teamId);
  };

  public shared ({ caller }) func voteOnMatchGroup(request : Types.VoteOnMatchGroupRequest) : async Types.VoteOnMatchGroupResult {
    let isOwner = await isTeamOwner(caller);
    if (not isOwner) {
      return #notAuthorized;
    };
    let leagueActor = actor (Principal.toText(leagueId)) : LeagueTypes.LeagueActor;
    let seasonStatus = try {
      await leagueActor.getSeasonStatus();
    } catch (err) {
      return #seasonStatusFetchError(Error.message(err));
    };
    let teamId = Principal.fromActor(this);
    let scheduledMatchGroup : Season.ScheduledMatchGroup = switch (seasonStatus) {
      case (#notStarted or #starting) return #votingNotOpen;
      case (#completed(c)) return #votingNotOpen;
      case (#inProgress(ip)) {
        let ?matchGroup = Util.arrayGetSafe(ip.matchGroups, request.matchGroupId) else return #matchGroupNotFound;

        switch (matchGroup) {
          case (#scheduled(scheduledMatchGroup)) {
            // TODO necessary to check in in group?
            let ?match = Array.find(
              scheduledMatchGroup.matches,
              func(m : Season.ScheduledMatch) : Bool = m.team1.id == teamId or m.team2.id == teamId,
            ) else return #teamNotInMatchGroup;
            scheduledMatchGroup;
          };
          case (_) return #votingNotOpen;
        };
      };
    };

    let errors = Buffer.Buffer<Types.InvalidVoteError>(0);
    let choiceExists = scheduledMatchGroup.scenario.options.size() > Nat8.toNat(request.scenarioChoice);
    if (not choiceExists) {
      errors.add(#invalidChoice(request.scenarioChoice));
    };
    if (errors.size() > 0) {
      return #invalid(Buffer.toArray(errors));
    };

    let matchGroupKey = buildMatchGroupKey(request.matchGroupId);
    let matchGroupVoteData = switch (Trie.get(matchGroupVotes, matchGroupKey, Nat.equal)) {
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
          Nat.equal,
          newMatchVotes,
        );
        matchGroupVotes := newMatchGroupVotes;
        #ok;
      };
    };
  };

  public shared query ({ caller }) func getMatchGroupVote(request : Types.GetMatchGroupVoteRequest) : async Types.GetMatchGroupVoteResult {
    if (caller != leagueId) {
      return #notAuthorized;
    };
    let matchGroupKey = buildMatchGroupKey(request.matchGroupId);
    let result = switch (Trie.get(matchGroupVotes, matchGroupKey, Nat.equal)) {
      case (null) #noVotes;
      case (?o) {
        let ?{ scenarioChoice } = tallyVotes(o) else return #noVotes;
        #ok({
          scenarioChoice = scenarioChoice;
        });
      };
    };
    result;
  };

  public shared ({ caller }) func onSeasonComplete() : async Types.OnSeasonCompleteResult {
    if (caller != leagueId) {
      return #notAuthorized;
    };
    matchGroupVotes := Trie.empty();
    #ok;
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

  private func buildMatchGroupKey(matchGroupId : Nat) : Trie.Key<Nat> {
    {
      key = matchGroupId;
      hash = Nat32.fromNat(matchGroupId); // TODO is this ok? numbers should be in the range of 0-2^32-1
    };
  };

  private func tallyVotes(matchVotes : Trie.Trie<Principal, Types.MatchGroupVote>) : ?Types.MatchGroupVote {
    // Scenario Option Id -> Vote Count
    var choiceVotes = Trie.empty<Nat8, Nat>();
    for ((userId, vote) in Trie.iter(matchVotes)) {
      let userVotingPower = 1; // TODO
      let scenarioKey = {
        key = vote.scenarioChoice;
        hash = Nat32.fromNat(Nat8.toNat(vote.scenarioChoice));
      };
      choiceVotes := addVotes(choiceVotes, scenarioKey, Nat8.equal, userVotingPower);
    };
    let ?winningChoice = calculateVote(choiceVotes) else return null;
    ?{
      scenarioChoice = winningChoice;
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
      case (?v) ?v.0;
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
