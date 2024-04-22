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

actor TeamsActor : Types.Actor {

  stable var stableData = {
    teams : [(Nat, TeamsHandler.StableData)] = [];
  };

  stable var leagueIdOrNull : ?Principal = null;

  var multiTeamHandler = TeamsHandler.MultiHandler<system>(stableData.teams);

  system func preupgrade() {
    stableData := {
      teams = multiTeamHandler.toStableData();
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

  public shared query func getTeams() : async [Team.Team] {
    multiTeamHandler.getTeams();
  };

  public shared ({ caller }) func createTeam(request : Types.CreateTeamRequest) : async Types.CreateTeamResult {
    let leagueId = switch (leagueIdOrNull) {
      case (null) Debug.trap("League not set");
      case (?id) id;
    };

    if (leagueId != caller) {
      return #notAuthorized;
    };
    await* multiTeamHandler.create(leagueId, request);
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

  public shared ({ caller }) func updateTeamEntropy(id : Nat, delta : Int) : async Types.UpdateTeamEntropyResult {
    let leagueId = switch (leagueIdOrNull) {
      case (null) Debug.trap("League not set");
      case (?id) id;
    };
    if (caller != leagueId) {
      return #notAuthorized;
    };
    let ?handler = multiTeamHandler.get(id) else return #teamNotFound;
    handler.updateEntropy(delta);
    #ok;
  };

  public shared ({ caller }) func updateTeamMotto(id : Nat, motto : Text) : async Types.UpdateTeamMottoResult {
    let leagueId = switch (leagueIdOrNull) {
      case (null) Debug.trap("League not set");
      case (?id) id;
    };
    if (caller != leagueId) {
      return #notAuthorized;
    };
    let ?handler = multiTeamHandler.get(id) else return #teamNotFound;
    handler.updateMotto(motto);
    #ok;
  };

  public shared ({ caller }) func updateTeamDescription(id : Nat, description : Text) : async Types.UpdateTeamDescriptionResult {
    let leagueId = switch (leagueIdOrNull) {
      case (null) Debug.trap("League not set");
      case (?id) id;
    };
    if (caller != leagueId) {
      return #notAuthorized;
    };
    let ?handler = multiTeamHandler.get(id) else return #teamNotFound;
    handler.updateDescription(description);
    #ok;
  };

  public shared ({ caller }) func updateTeamLogo(id : Nat, logoUrl : Text) : async Types.UpdateTeamLogoResult {
    let leagueId = switch (leagueIdOrNull) {
      case (null) Debug.trap("League not set");
      case (?id) id;
    };
    if (caller != leagueId) {
      return #notAuthorized;
    };
    let ?handler = multiTeamHandler.get(id) else return #teamNotFound;
    handler.updateLogo(logoUrl);
    #ok;
  };

  public shared ({ caller }) func updateTeamColor(id : Nat, color : (Nat8, Nat8, Nat8)) : async Types.UpdateTeamColorResult {
    let leagueId = switch (leagueIdOrNull) {
      case (null) Debug.trap("League not set");
      case (?id) id;
    };
    if (caller != leagueId) {
      return #notAuthorized;
    };
    let ?handler = multiTeamHandler.get(id) else return #teamNotFound;
    handler.updateColor(color);
    #ok;
  };

  public shared ({ caller }) func updateTeamName(id : Nat, name : Text) : async Types.UpdateTeamNameResult {
    let leagueId = switch (leagueIdOrNull) {
      case (null) Debug.trap("League not set");
      case (?id) id;
    };
    if (caller != leagueId) {
      return #notAuthorized;
    };
    let ?handler = multiTeamHandler.get(id) else return #teamNotFound;
    handler.updateName(name);
    #ok;
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
