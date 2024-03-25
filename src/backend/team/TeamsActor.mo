import Principal "mo:base/Principal";
import Nat "mo:base/Nat";
import Debug "mo:base/Debug";
import Iter "mo:base/Iter";
import { ic } "mo:ic";
import Types "Types";
import TeamsHandler "TeamsHandler";
import ScenarioHandler "ScenarioHandler";
import UsersActor "canister:users";
import Dao "../Dao";

actor TeamsActor : Types.Actor {

  stable var stableData = {
    teams : [(Nat, TeamsHandler.StableData)] = [];
    scenarios : [ScenarioHandler.StableData] = [];
  };

  stable var leagueIdOrNull : ?Principal = null;

  var multiTeamHandler = TeamsHandler.MultiHandler<system>(stableData.teams);

  var scenarioMultiHandler = ScenarioHandler.MultiHandler(stableData.scenarios);

  system func preupgrade() {
    stableData := {
      teams = multiTeamHandler.toStableData();
      scenarios = scenarioMultiHandler.toStableData();
    };
  };

  system func postupgrade() {
    multiTeamHandler := TeamsHandler.MultiHandler<system>(stableData.teams);
  };

  public shared ({ caller }) func setLeague(id : Principal) : async Types.SetLeagueResult {
    // TODO how to get the league id vs manual set
    // Set if the league is not set or if the caller is the league
    if (leagueIdOrNull == null or leagueIdOrNull == ?caller) {
      leagueIdOrNull := ?id;
      return #ok;
    };
    #notAuthorized;
  };

  public shared ({ caller }) func createTeam(_ : Types.CreateTeamRequest) : async Types.CreateTeamResult {
    let leagueId = switch (leagueIdOrNull) {
      case (null) Debug.trap("League not set");
      case (?id) id;
    };

    if (leagueId != caller) {
      return #notAuthorized;
    };
    let (id, _) = multiTeamHandler.create(leagueId);
    #ok({
      id = id;
    });

  };

  public shared ({ caller }) func voteOnScenario(teamId : Nat, request : Types.VoteOnScenarioRequest) : async Types.VoteOnScenarioResult {
    let ?handler = scenarioMultiHandler.getHandler(request.scenarioId) else return #scenarioNotFound;
    switch (await UsersActor.get(caller)) {
      case (#ok(user)) {
        let ?team = user.team else return #notAuthorized;
        if (team.id != teamId) {
          return #notAuthorized;
        };
        let #owner(o) = team.kind else return #notAuthorized;
        handler.vote(caller, teamId, o.votingPower, request.option);
      };
      case (#notFound or #notAuthorized) #notAuthorized;
    };
  };

  public shared query ({ caller }) func getScenarioVote(request : Types.GetScenarioVoteRequest) : async Types.GetScenarioVoteResult {
    let ?handler = scenarioMultiHandler.getHandler(request.scenarioId) else return #scenarioNotFound;
    #ok(handler.getVote(caller));
  };

  public shared ({ caller }) func createProposal(teamId : Nat, request : Types.CreateProposalRequest) : async Types.CreateProposalResult {
    let members = switch (await UsersActor.getTeamOwners(#team(teamId))) {
      case (#ok(members)) members;
    };
    let isAMember = members
    |> Iter.fromArray(_)
    |> Iter.filter(
      _,
      func(member : Dao.Member) : Bool = member.id == caller,
    )
    |> _.next() != null;
    if (not isAMember) {
      return #notAuthorized;
    };
    let ?teamHandler = multiTeamHandler.get(teamId) else return #teamNotFound;
    teamHandler.createProposal<system>(caller, request, members);
  };

  public shared query func getProposal(teamId : Nat, id : Nat) : async Types.GetProposalResult {
    let ?teamHandler = multiTeamHandler.get(teamId) else return #teamNotFound;
    switch (teamHandler.getProposal(id)) {
      case (null) #proposalNotFound;
      case (?proposal) #ok(proposal);
    };
  };

  public shared query func getProposals(teamId : Nat, count : Nat, offset : Nat) : async Types.GetProposalsResult {
    let ?teamHandler = multiTeamHandler.get(teamId) else return #teamNotFound;
    #ok(teamHandler.getProposals(count, offset));
  };

  public shared ({ caller }) func voteOnProposal(teamId : Nat, request : Types.VoteOnProposalRequest) : async Types.VoteOnProposalResult {
    let ?teamHandler = multiTeamHandler.get(teamId) else return #teamNotFound;
    await* teamHandler.voteOnProposal(caller, request);
  };

  public shared ({ caller }) func getScenarioVotingResults(request : Types.GetScenarioVotingResultsRequest) : async Types.GetScenarioVotingResultsResult {
    let leagueId = switch (leagueIdOrNull) {
      case (null) Debug.trap("League not set");
      case (?id) id;
    };
    if (caller != leagueId) {
      return #notAuthorized;
    };
    let ?handler = scenarioMultiHandler.getHandler(request.scenarioId) else return #scenarioNotFound;
    let results = handler.calculateResults();
    #ok(results);
  };

  public shared ({ caller }) func onNewScenario(request : Types.OnNewScenarioRequest) : async Types.OnNewScenarioResult {
    Debug.print("onNewScenario called: " # debug_show (request));
    let leagueId = switch (leagueIdOrNull) {
      case (null) Debug.trap("League not set");
      case (?id) id;
    };
    if (caller != leagueId) {
      return #notAuthorized;
    };
    scenarioMultiHandler.add(request.scenarioId, request.optionCount);
    #ok;
  };

  public shared ({ caller }) func onScenarioVoteComplete(request : Types.OnScenarioVoteCompleteRequest) : async Types.OnScenarioVoteCompleteResult {
    let leagueId = switch (leagueIdOrNull) {
      case (null) Debug.trap("League not set");
      case (?id) id;
    };
    if (caller != leagueId) {
      return #notAuthorized;
    };
    switch (scenarioMultiHandler.remove(request.scenarioId)) {
      case (#ok) #ok;
      case (#notFound) #scenarioNotFound;
    };
  };

  public shared ({ caller }) func onSeasonEnd() : async Types.OnSeasonEndResult {
    let leagueId = switch (leagueIdOrNull) {
      case (null) Debug.trap("League not set");
      case (?id) id;
    };
    if (caller != leagueId) {
      return #notAuthorized;
    };
    // TODO
    #ok;
  };

  public shared ({ caller }) func getCycles() : async Types.GetCyclesResult {
    let leagueId = switch (leagueIdOrNull) {
      case (null) Debug.trap("League not set");
      case (?id) id;
    };
    if (caller != leagueId) {
      return #notAuthorized;
    };
    let canisterStatus = await ic.canister_status({
      canister_id = Principal.fromActor(TeamsActor);
    });
    return #ok(canisterStatus.cycles);
  };
};
