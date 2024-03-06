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
import TeamState "./TeamState";
import TeamDao "./TeamDao";
import ScenarioVoteHandler "ScenarioVoteHandler";

shared (install) actor class TeamActor(
  leagueId : Principal,
  playersActorId : Principal,
) : async Types.TeamActor = this {

  stable var scenarioVoteData = Trie.empty<Text, ScenarioVoteHandler.Data>();
  stable let dao = TeamDao.TeamDao();
  stable let team = TeamState.TeamState(Principal.fromActor(this), leagueId);

  public composite query func getPlayers() : async [Player.PlayerWithId] {
    let teamId = Principal.fromActor(this);
    let playersActor = actor (Principal.toText(playersActorId)) : PlayersTypes.PlayerActor;
    await playersActor.getTeamPlayers(teamId);
  };

  public shared ({ caller }) func voteOnScenario(request : Types.VoteOnScenarioRequest) : async Types.VoteOnScenarioResult {
    let ?handler = getScenarioVoteHandler(request.scenarioId) else return #scenarioNotFound;
    handler.vote(caller, request.option);
  };

  public shared query ({ caller }) func getScenarioVote(request : Types.GetScenarioVoteRequest) : async Types.GetScenarioVoteResult {
    let ?handler = getScenarioVoteHandler(request.scenarioId) else return #scenarioNotFound;
    #ok(handler.getVote(caller));
  };

  private func getScenarioVoteHandler(scenarioId : Text) : ?ScenarioVoteHandler.Handler {
    let scenarioKey = {
      key = scenarioId;
      hash = Text.hash(scenarioId);
    };
    let ?data = Trie.get(scenarioVoteData, scenarioKey, Text.equal) else return null;
    return ?ScenarioVoteHandler.Handler(data);
  };

  public shared ({ caller }) func getWinningScenarioOption(request : Types.GetWinningScenarioOptionRequest) : async Types.GetWinningScenarioOptionResult {
    if (caller != leagueId) {
      return #notAuthorized;
    };
    let ?handler = getScenarioVoteHandler(request.scenarioId) else return #scenarioNotFound;
    let ?winningOption = handler.calculateWinningOption() else return #noVotes;
    #ok(winningOption);
  };

  public shared ({ caller }) func onNewScenario(request : Types.OnNewScenarioRequest) : async Types.OnNewScenarioResult {
    if (caller != leagueId) {
      return #notAuthorized;
    };
    let data : ScenarioVoteHandler.Data = {
      optionCount = request.optionCount;
      votes = Trie.empty<Principal, Nat>();
    };
    let scenarioKey = {
      key = request.scenarioId;
      hash = Text.hash(request.scenarioId);
    };
    let newScenarioVoteData = switch (Trie.put(scenarioVoteData, scenarioKey, Text.equal, data)) {
      case ((new, null)) new;
      case ((_, ?existingData)) Debug.trap("Scenario with id " # request.scenarioId # " already exists");
    };
    scenarioVoteData := newScenarioVoteData;
    #ok;
  };

  public shared ({ caller }) func onScenarioVoteComplete(request : Types.OnScenarioVoteCompleteRequest) : async Types.OnScenarioVoteCompleteResult {
    if (caller != leagueId) {
      return #notAuthorized;
    };
    let scenarioKey = {
      key = request.scenarioId;
      hash = Text.hash(request.scenarioId);
    };
    let (newScenarioVoteData, _) = Trie.remove(scenarioVoteData, scenarioKey, Text.equal);
    scenarioVoteData := newScenarioVoteData;
    #ok;
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
