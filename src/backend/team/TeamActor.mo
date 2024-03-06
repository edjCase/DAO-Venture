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
import HashMap "mo:base/HashMap";
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
import TeamState "./TeamState";
import TeamDao "./TeamDao";
import ScenarioVoting "ScenarioVoting";

shared (install) actor class TeamActor(
  leagueId : Principal,
  playersActorId : Principal,
) : async Types.TeamActor = this {

  stable var stableData = {
    scenarioVoting : [ScenarioVoting.Data] = [];
    dao : TeamDao.Data = {
      members = [];
    };
  };

  var dao = TeamDao.TeamDao(stableData.dao);

  var scenarioVotingManager = ScenarioVoting.Manager(stableData.scenarioVoting);

  system func preupgrade() {
    stableData := {
      scenarioVoting = scenarioVotingManager.toData();
      dao = dao.toData();
    };
  };

  system func postupgrade() {
    dao := TeamDao.TeamDao(stableData.dao);
    scenarioVotingManager := ScenarioVoting.Manager(stableData.scenarioVoting);
  };

  public composite query func getPlayers() : async [Player.PlayerWithId] {
    let teamId = Principal.fromActor(this);
    let playersActor = actor (Principal.toText(playersActorId)) : PlayersTypes.PlayerActor;
    await playersActor.getTeamPlayers(teamId);
  };

  public shared ({ caller }) func voteOnScenario(request : Types.VoteOnScenarioRequest) : async Types.VoteOnScenarioResult {
    let ?handler = scenarioVotingManager.getHandler(request.scenarioId) else return #scenarioNotFound;
    let ?member = dao.getMember(caller) else return #notAuthorized;
    handler.vote(caller, member.votingPower, request.option);
  };

  public shared query ({ caller }) func getScenarioVote(request : Types.GetScenarioVoteRequest) : async Types.GetScenarioVoteResult {
    let ?handler = scenarioVotingManager.getHandler(request.scenarioId) else return #scenarioNotFound;
    #ok(handler.getVote(caller));
  };

  public shared ({ caller }) func getWinningScenarioOption(request : Types.GetWinningScenarioOptionRequest) : async Types.GetWinningScenarioOptionResult {
    if (caller != leagueId) {
      return #notAuthorized;
    };
    let ?handler = scenarioVotingManager.getHandler(request.scenarioId) else return #scenarioNotFound;
    let ?winningOption = handler.calculateWinningOption() else return #noVotes;
    #ok(winningOption);
  };

  public shared ({ caller }) func onNewScenario(request : Types.OnNewScenarioRequest) : async Types.OnNewScenarioResult {
    if (caller != leagueId) {
      return #notAuthorized;
    };
    scenarioVotingManager.add(request.scenarioId, request.optionCount);
    #ok;
  };

  public shared ({ caller }) func onScenarioVoteComplete(request : Types.OnScenarioVoteCompleteRequest) : async Types.OnScenarioVoteCompleteResult {
    if (caller != leagueId) {
      return #notAuthorized;
    };
    switch (scenarioVotingManager.remove(request.scenarioId)) {
      case (#ok) #ok;
      case (#notFound) #scenarioNotFound;
    };
  };

  public shared ({ caller }) func onSeasonComplete() : async Types.OnSeasonCompleteResult {
    if (caller != leagueId) {
      return #notAuthorized;
    };
    // TODO
    #ok;
  };

  public shared ({ caller }) func getCycles() : async Types.GetCyclesResult {
    if (caller != leagueId) {
      return #notAuthorized;
    };
    let canisterStatus = await ic.canister_status({
      canister_id = Principal.fromActor(this);
    });
    return #ok(canisterStatus.cycles);
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
