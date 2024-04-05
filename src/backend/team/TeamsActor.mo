import Principal "mo:base/Principal";
import Nat "mo:base/Nat";
import Debug "mo:base/Debug";
import Iter "mo:base/Iter";
import Prelude "mo:base/Prelude";
import { ic } "mo:ic";
import Types "Types";
import TeamsHandler "TeamsHandler";
import ScenarioHandler "ScenarioHandler";
import UsersActor "canister:users";
import Dao "../Dao";
import UserTypes "../users/Types";

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
    scenarioMultiHandler := ScenarioHandler.MultiHandler(stableData.scenarios);
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

  public shared ({ caller }) func updateTeamEnergy(id : Nat, delta : Int) : async Types.UpdateTeamEnergyResult {
    let leagueId = switch (leagueIdOrNull) {
      case (null) Debug.trap("League not set");
      case (?id) id;
    };
    if (caller != leagueId) {
      return #notAuthorized;
    };
    let ?handler = multiTeamHandler.get(id) else return #teamNotFound;
    switch (handler.updateEnergy(delta, true)) {
      case (#ok) #ok;
      case (#notEnoughEnergy) Prelude.unreachable(); // Only happens when 0 energy is min
    };
  };

  public shared ({ caller }) func voteOnScenario(request : Types.VoteOnScenarioRequest) : async Types.VoteOnScenarioResult {
    let ?handler = scenarioMultiHandler.getHandler(request.scenarioId) else return #scenarioNotFound;
    handler.vote(caller, request.option);
  };

  public shared query ({ caller }) func getScenarioVote(request : Types.GetScenarioVoteRequest) : async Types.GetScenarioVoteResult {
    let ?handler = scenarioMultiHandler.getHandler(request.scenarioId) else return #scenarioNotFound;
    handler.getVote(caller);
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

  public shared ({ caller }) func onScenarioStart(request : Types.OnScenarioStartRequest) : async Types.OnScenarioStartResult {
    Debug.print("OnScenarioStart called: " # debug_show (request));
    let leagueId = switch (leagueIdOrNull) {
      case (null) Debug.trap("League not set");
      case (?id) id;
    };
    if (caller != leagueId) {
      return #notAuthorized;
    };
    switch (await UsersActor.getTeamOwners(#all)) {
      case (#ok(members)) {
        let eligibleVoters = members.vals()
        |> Iter.map<UserTypes.UserVotingInfo, ScenarioHandler.VoterInfo>(
          _,
          func(member : UserTypes.UserVotingInfo) : ScenarioHandler.VoterInfo = {
            id = member.id;
            teamId = member.teamId;
            votingPower = member.votingPower;
          },
        )
        |> Iter.toArray(_);
        scenarioMultiHandler.add(request.scenarioId, request.optionCount, eligibleVoters);
        #ok;
      };
    };
  };

  public shared ({ caller }) func onScenarioEnd(request : Types.OnScenarioEndRequest) : async Types.OnScenarioEndResult {
    let leagueId = switch (leagueIdOrNull) {
      case (null) Debug.trap("League not set");
      case (?id) id;
    };
    if (caller != leagueId) {
      return #notAuthorized;
    };
    switch (scenarioMultiHandler.remove(request.scenarioId)) {
      case (#ok) {
        for ({ teamId; energy } in request.energyDividends.vals()) {
          let ?handler = multiTeamHandler.get(teamId) else Debug.trap("Team not found: " # Nat.toText(teamId)); // TODO trap?
          ignore handler.updateEnergy(energy, true);
        };
        #ok;
      };
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

  public query func getLinks() : async Types.GetLinksResult {
    let teamHandlers = multiTeamHandler.getAll();
    let links = teamHandlers.vals()
    |> Iter.map(
      _,
      func((teamId, handler) : (Nat, TeamsHandler.Handler)) : Types.TeamLinks = {
        teamId = teamId;
        links = handler.getLinks();
      },
    )
    |> Iter.toArray(_);
    #ok(links);
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
