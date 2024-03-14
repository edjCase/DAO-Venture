import Principal "mo:base/Principal";
import Nat "mo:base/Nat";
import { ic } "mo:ic";
import Types "Types";
import TeamsHandler "TeamsHandler";

actor : Types.TeamActor {

  stable var stableData = {
    teams : [TeamsHandler.StableData] = [];
  };
  stable var leagueIdOrNull : ?Principal = null;

  var multiTeamHandler = TeamsHandler.MultiHandler(leagueId, stableData.teams);

  system func preupgrade() {
    stableData := {
      teams = multiTeamHandler.toStableData();
    };
  };

  system func postupgrade() {
    multiTeamHandler := TeamsHandler.MultiHandler(stableData.teams);
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

  public shared ({ caller }) func createTeam(request : Types.CreateTeamRequest) : async Types.CreateTeamResult {
    if (leagueIdOrNull != ?caller) {
      return #notAuthorized;
    };
    multiTeamHandler.create(request);

  };

  public shared ({ caller }) func voteOnScenario(request : Types.VoteOnScenarioRequest) : async Types.VoteOnScenarioResult {
    let ?teamHandler = multiTeamHandler.get(request.teamId) else return #teamNotFound;
    teamHandler.voteOnScenario(request.scenarioId, request.option);
  };

  public shared query ({ caller }) func getScenarioVote(request : Types.GetScenarioVoteRequest) : async Types.GetScenarioVoteResult {
    let ?teamHandler = multiTeamHandler.get(request.teamId) else return #teamNotFound;
    teamHandler.getScenarioVote(request.scenarioId, caller);
  };

  public shared ({ caller }) func createProposal(request : Types.CreateProposalRequest) : async Types.CreateProposalResult {
    let members = switch (await usersActor.getTeamOwners(#team(Principal.fromActor(this)))) {
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
    let ?teamHandler = multiTeamHandler.get(request.teamId) else return #teamNotFound;
    teamHandler.createProposal<system>(caller, request.content, members);
  };

  public shared query func getProposal(id : Nat) : async ?Types.Proposal {
    let ?teamHandler = multiTeamHandler.get(request.teamId) else return #teamNotFound;
    teamHandler.getProposal(id);
  };

  public shared query func getProposals() : async [Types.Proposal] {
    let ?teamHandler = multiTeamHandler.get(request.teamId) else return #teamNotFound;
    teamHandler.getProposals();
  };

  public shared ({ caller }) func voteOnProposal(request : Types.VoteOnProposalRequest) : async Types.VoteOnProposalResult {
    let ?teamHandler = multiTeamHandler.get(request.teamId) else return #teamNotFound;
    await* teamHandler.vote(request.proposalId, caller, request.vote);
  };

  public shared ({ caller }) func getWinningScenarioOption(request : Types.GetWinningScenarioOptionRequest) : async Types.GetWinningScenarioOptionResult {
    if (caller != leagueId) {
      return #notAuthorized;
    };
    let ?teamHandler = multiTeamHandler.get(request.teamId) else return #teamNotFound;
    teamHandler.getWinningScenarioOption(request.scenarioId);
  };

  public shared ({ caller }) func onNewScenario(request : Types.OnNewScenarioRequest) : async Types.OnNewScenarioResult {
    if (caller != leagueId) {
      return #notAuthorized;
    };
    let ?teamHandler = multiTeamHandler.get(request.teamId) else return #teamNotFound;
    teamHandler.onNewScenario(request.scenarioId, request.optionCount);
    #ok;
  };

  public shared ({ caller }) func onScenarioVoteComplete(request : Types.OnScenarioVoteCompleteRequest) : async Types.OnScenarioVoteCompleteResult {
    if (caller != leagueId) {
      return #notAuthorized;
    };
    let ?teamHandler = multiTeamHandler.get(request.teamId) else return #teamNotFound;
    teamHandler.onScenarioVoteComplete(request);
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
};
