import Principal "mo:base/Principal";
import Nat "mo:base/Nat";
import Debug "mo:base/Debug";
import Iter "mo:base/Iter";
import Prelude "mo:base/Prelude";
import { ic } "mo:ic";
import Types "Types";
import TeamsHandler "TeamsHandler";
import UsersActor "canister:users";
import Dao "../Dao";
import Team "../models/Team";
import Result "mo:base/Result";

actor TeamsActor : Types.Actor {

  stable var stableData = {
    teams : TeamsHandler.StableData = {
      entropyThreshold = 100;
      traits = [];
      teams = [];
    };
  };

  stable var leagueIdOrNull : ?Principal = null;

  var teamsHandler = TeamsHandler.Handler<system>(stableData.teams);

  system func preupgrade() {
    stableData := {
      teams = teamsHandler.toStableData();
    };
  };

  system func postupgrade() {
    teamsHandler := TeamsHandler.Handler<system>(stableData.teams);
  };

  public shared ({ caller }) func setLeague(id : Principal) : async Types.SetLeagueResult {
    // TODO how to get the league id vs manual set
    // Set if the league is not set or if the caller is the league
    if (leagueIdOrNull == null or leagueIdOrNull == ?caller) {
      leagueIdOrNull := ?id;
      return #ok;
    };
    #err(#notAuthorized);
  };

  public shared query func getTeams() : async [Team.Team] {
    teamsHandler.getAll();
  };

  public shared ({ caller }) func createTeam(request : Types.CreateTeamRequest) : async Types.CreateTeamResult {
    let leagueId = switch (leagueIdOrNull) {
      case (null) Debug.trap("League not set");
      case (?id) id;
    };

    if (leagueId != caller) {
      return #err(#notAuthorized);
    };
    await* teamsHandler.create(leagueId, request);
  };

  public shared ({ caller }) func updateTeamEnergy(id : Nat, delta : Int) : async Types.UpdateTeamEnergyResult {
    let leagueId = switch (leagueIdOrNull) {
      case (null) Debug.trap("League not set");
      case (?id) id;
    };
    if (caller != leagueId) {
      return #err(#notAuthorized);
    };
    switch (teamsHandler.updateEnergy(id, delta, true)) {
      case (#ok) #ok;
      case (#err(#teamNotFound)) #err(#teamNotFound);
      case (#err(#notEnoughEnergy)) Prelude.unreachable(); // Only happens when 0 energy is min
    };
  };

  public shared ({ caller }) func updateTeamEntropy(id : Nat, delta : Int) : async Types.UpdateTeamEntropyResult {
    let leagueId = switch (leagueIdOrNull) {
      case (null) Debug.trap("League not set");
      case (?id) id;
    };
    if (caller != leagueId) {
      return #err(#notAuthorized);
    };
    await* teamsHandler.updateEntropy(id, delta);
  };

  public shared ({ caller }) func updateTeamMotto(id : Nat, motto : Text) : async Types.UpdateTeamMottoResult {
    let leagueId = switch (leagueIdOrNull) {
      case (null) Debug.trap("League not set");
      case (?id) id;
    };
    if (caller != leagueId) {
      return #err(#notAuthorized);
    };
    teamsHandler.updateMotto(id, motto);
  };

  public shared ({ caller }) func updateTeamDescription(id : Nat, description : Text) : async Types.UpdateTeamDescriptionResult {
    let leagueId = switch (leagueIdOrNull) {
      case (null) Debug.trap("League not set");
      case (?id) id;
    };
    if (caller != leagueId) {
      return #err(#notAuthorized);
    };
    teamsHandler.updateDescription(id, description);
  };

  public shared ({ caller }) func updateTeamLogo(id : Nat, logoUrl : Text) : async Types.UpdateTeamLogoResult {
    let leagueId = switch (leagueIdOrNull) {
      case (null) Debug.trap("League not set");
      case (?id) id;
    };
    if (caller != leagueId) {
      return #err(#notAuthorized);
    };
    teamsHandler.updateLogo(id, logoUrl);
  };

  public shared ({ caller }) func updateTeamColor(id : Nat, color : (Nat8, Nat8, Nat8)) : async Types.UpdateTeamColorResult {
    let leagueId = switch (leagueIdOrNull) {
      case (null) Debug.trap("League not set");
      case (?id) id;
    };
    if (caller != leagueId) {
      return #err(#notAuthorized);
    };
    teamsHandler.updateColor(id, color);
  };

  public shared ({ caller }) func updateTeamName(id : Nat, name : Text) : async Types.UpdateTeamNameResult {
    let leagueId = switch (leagueIdOrNull) {
      case (null) Debug.trap("League not set");
      case (?id) id;
    };
    if (caller != leagueId) {
      return #err(#notAuthorized);
    };
    teamsHandler.updateName(id, name);
  };

  public shared ({ caller }) func addTeamTrait(id : Nat, traitId : Text) : async Types.AddTeamTraitResult {
    let leagueId = switch (leagueIdOrNull) {
      case (null) Debug.trap("League not set");
      case (?id) id;
    };
    if (caller != leagueId) {
      return #err(#notAuthorized);
    };
    teamsHandler.addTrait(id, traitId);
  };

  public shared ({ caller }) func removeTeamTrait(id : Nat, traitId : Text) : async Types.RemoveTeamTraitResult {
    let leagueId = switch (leagueIdOrNull) {
      case (null) Debug.trap("League not set");
      case (?id) id;
    };
    if (caller != leagueId) {
      return #err(#notAuthorized);
    };
    teamsHandler.removeTrait(id, traitId);
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
      return #err(#notAuthorized);
    };
    teamsHandler.createProposal<system>(teamId, caller, request, members);
  };

  public shared query func getProposal(teamId : Nat, id : Nat) : async Types.GetProposalResult {
    teamsHandler.getProposal(teamId, id);
  };

  public shared query func getProposals(teamId : Nat, count : Nat, offset : Nat) : async Types.GetProposalsResult {
    teamsHandler.getProposals(teamId, count, offset);
  };

  public shared ({ caller }) func voteOnProposal(teamId : Nat, request : Types.VoteOnProposalRequest) : async Types.VoteOnProposalResult {
    await* teamsHandler.voteOnProposal(teamId, caller, request);
  };

  public shared ({ caller }) func onMatchGroupComplete(request : Types.OnMatchGroupCompleteRequest) : async Result.Result<(), Types.OnMatchGroupCompleteError> {
    let leagueId = switch (leagueIdOrNull) {
      case (null) Debug.trap("League not set");
      case (?id) id;
    };
    if (caller != leagueId) {
      return #err(#notAuthorized);
    };
    teamsHandler.onMatchGroupComplete(request.matchGroup);
    #ok;
  };

  public shared ({ caller }) func onSeasonEnd() : async Types.OnSeasonEndResult {
    let leagueId = switch (leagueIdOrNull) {
      case (null) Debug.trap("League not set");
      case (?id) id;
    };
    if (caller != leagueId) {
      return #err(#notAuthorized);
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
      return #err(#notAuthorized);
    };
    let canisterStatus = await ic.canister_status({
      canister_id = Principal.fromActor(TeamsActor);
    });
    return #ok(canisterStatus.cycles);
  };
};
