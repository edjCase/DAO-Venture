import Principal "mo:base/Principal";
import Nat "mo:base/Nat";
import Iter "mo:base/Iter";
import Prelude "mo:base/Prelude";
import { ic } "mo:ic";
import Types "Types";
import TeamsHandler "TeamsHandler";
import Dao "../Dao";
import Team "../models/Team";
import Result "mo:base/Result";
import Trait "../models/Trait";
import LeagueTypes "../league/Types";
import UserTypes "../users/Types";

actor class TeamsActor(
  leagueCanisterId : Principal,
  usersCanisterId : Principal,
  playersCanisterId : Principal,
) : async Types.Actor = this {

  let usersActor = actor (Principal.toText(usersCanisterId)) : UserTypes.Actor;

  stable var teamStableData : TeamsHandler.StableData = {
    entropyThreshold = 100;
    traits = [];
    teams = [];
  };

  var teamsHandler = TeamsHandler.Handler<system>(teamStableData, leagueCanisterId, playersCanisterId);

  system func preupgrade() {
    teamStableData := teamsHandler.toStableData();
  };

  system func postupgrade() {
    teamsHandler := TeamsHandler.Handler<system>(teamStableData, leagueCanisterId, playersCanisterId);
  };

  public shared query func getTeams() : async [Team.Team] {
    teamsHandler.getAll();
  };

  public shared ({ caller }) func createTeam(request : Types.CreateTeamRequest) : async Types.CreateTeamResult {
    if (not (await* isLeagueOrBDFN(caller))) {
      return #err(#notAuthorized);
    };
    await* teamsHandler.create(request);
  };

  public shared ({ caller }) func updateTeamEnergy(id : Nat, delta : Int) : async Types.UpdateTeamEnergyResult {
    if (not (await* isLeagueOrBDFN(caller))) {
      return #err(#notAuthorized);
    };
    switch (teamsHandler.updateEnergy(id, delta, true)) {
      case (#ok) #ok;
      case (#err(#teamNotFound)) #err(#teamNotFound);
      case (#err(#notEnoughEnergy)) Prelude.unreachable(); // Only happens when 0 energy is min
    };
  };

  public shared ({ caller }) func updateTeamEntropy(id : Nat, delta : Int) : async Types.UpdateTeamEntropyResult {
    if (not (await* isLeagueOrBDFN(caller))) {
      return #err(#notAuthorized);
    };
    await* teamsHandler.updateEntropy(id, delta);
  };

  public shared ({ caller }) func updateTeamMotto(id : Nat, motto : Text) : async Types.UpdateTeamMottoResult {
    if (not (await* isLeagueOrBDFN(caller))) {
      return #err(#notAuthorized);
    };
    teamsHandler.updateMotto(id, motto);
  };

  public shared ({ caller }) func updateTeamDescription(id : Nat, description : Text) : async Types.UpdateTeamDescriptionResult {
    if (not (await* isLeagueOrBDFN(caller))) {
      return #err(#notAuthorized);
    };
    teamsHandler.updateDescription(id, description);
  };

  public shared ({ caller }) func updateTeamLogo(id : Nat, logoUrl : Text) : async Types.UpdateTeamLogoResult {
    if (not (await* isLeagueOrBDFN(caller))) {
      return #err(#notAuthorized);
    };
    teamsHandler.updateLogo(id, logoUrl);
  };

  public shared ({ caller }) func updateTeamColor(id : Nat, color : (Nat8, Nat8, Nat8)) : async Types.UpdateTeamColorResult {
    if (not (await* isLeagueOrBDFN(caller))) {
      return #err(#notAuthorized);
    };
    teamsHandler.updateColor(id, color);
  };

  public shared ({ caller }) func updateTeamName(id : Nat, name : Text) : async Types.UpdateTeamNameResult {
    if (not (await* isLeagueOrBDFN(caller))) {
      return #err(#notAuthorized);
    };
    teamsHandler.updateName(id, name);
  };

  public shared query func getTraits() : async [Trait.Trait] {
    teamsHandler.getTraits();
  };

  public shared ({ caller }) func createTeamTrait(request : Types.CreateTeamTraitRequest) : async Types.CreateTeamTraitResult {
    if (not (await* isLeagueOrBDFN(caller))) {
      return #err(#notAuthorized);
    };
    teamsHandler.createTrait(request);
  };

  public shared ({ caller }) func addTraitToTeam(teamId : Nat, traitId : Text) : async Types.AddTraitToTeamResult {
    if (not (await* isLeagueOrBDFN(caller))) {
      return #err(#notAuthorized);
    };
    teamsHandler.addTraitToTeam(teamId, traitId);
  };

  public shared ({ caller }) func removeTraitFromTeam(teamId : Nat, traitId : Text) : async Types.RemoveTraitFromTeamResult {
    if (not (await* isLeagueOrBDFN(caller))) {
      return #err(#notAuthorized);
    };
    teamsHandler.removeTraitFromTeam(teamId, traitId);
  };

  public shared ({ caller }) func createProposal(teamId : Nat, request : Types.CreateProposalRequest) : async Types.CreateProposalResult {
    let members = switch (await usersActor.getTeamOwners(#team(teamId))) {
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

  public shared ({ caller }) func onMatchGroupComplete(
    request : Types.OnMatchGroupCompleteRequest
  ) : async Result.Result<(), Types.OnMatchGroupCompleteError> {
    if (not (await* isLeagueOrBDFN(caller))) {
      return #err(#notAuthorized);
    };
    teamsHandler.onMatchGroupComplete(request.matchGroup);
    #ok;
  };

  public shared ({ caller }) func onSeasonEnd() : async Types.OnSeasonEndResult {
    if (not (await* isLeagueOrBDFN(caller))) {
      return #err(#notAuthorized);
    };
    // TODO
    #ok;
  };

  public shared ({ caller }) func getCycles() : async Types.GetCyclesResult {
    if (not (await* isLeagueOrBDFN(caller))) {
      return #err(#notAuthorized);
    };
    let canisterStatus = await ic.canister_status({
      canister_id = Principal.fromActor(this);
    });
    return #ok(canisterStatus.cycles);
  };

  private func isLeagueOrBDFN(caller : Principal) : async* Bool {
    if (leagueCanisterId == caller) {
      return true;
    };
    // TODO change to league push new bdfn vs fetch?
    let leagueActor = actor (Principal.toText(leagueCanisterId)) : LeagueTypes.LeagueActor;
    switch (await leagueActor.getBenevolentDictatorState()) {
      case (#claimed(bdfnId)) caller == bdfnId;
      case (#disabled or #open) false;
    };
  };
};
