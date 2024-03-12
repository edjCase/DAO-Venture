import Principal "mo:base/Principal";
import Debug "mo:base/Debug";
import Nat "mo:base/Nat";
import Iter "mo:base/Iter";
import { ic } "mo:ic";
import Types "Types";
import ScenarioVoting "ScenarioVoting";
import Dao "../Dao";
// TODO cant use because of generating did files for JS/TS
// import UsersActor "cansiter:users";
import UserTypes "../users/Types";
import LeagueTypes "../league/Types";

shared (install) actor class TeamActor(
  leagueId : Principal,
  usersActorId : Principal,
) : async Types.TeamActor = this {

  let usersActor = actor (Principal.toText(usersActorId)) : UserTypes.Actor;

  stable var stableData = {
    scenarioVoting : [ScenarioVoting.StableData] = [];
    dao : Dao.StableData<Types.ProposalContent> = {
      proposals = [];
      proposalDuration = #days(3);
      votingThreshold = #percent({
        percent = 50;
        quorum = ?20;
      });
    };
  };

  func onExecute(proposal : Dao.Proposal<Types.ProposalContent>) : async* Dao.OnExecuteResult {
    switch (proposal.content) {
      case (#trainPlayer(trainPlayer)) {
        // TODO
        Debug.print("Training player: " # debug_show (trainPlayer));
        #ok;
      };
      case (#changeName(n)) {
        let leagueActor = actor (Principal.toText(leagueId)) : LeagueTypes.LeagueActor;
        let result = await leagueActor.createProposal({
          content = #changeTeamName({
            teamId = Principal.fromActor(this);
            name = n.name;
          });
        });
        switch (result) {
          case (#ok(_)) #ok;
          case (#notAuthorized) #err("Not authorized to create change name proposal in league DAO");
        };
      };
    };
  };

  func onReject(proposal : Dao.Proposal<Types.ProposalContent>) : async* () {
    Debug.print("Rejected proposal: " # debug_show (proposal));
  };

  // TODO this getDao is a bit of a hack due to Principal.fromActor(this) not being allowed in constructor
  var daoOrNull : ?Dao.Dao<Types.ProposalContent> = null;

  private func getDao<system>() : Dao.Dao<Types.ProposalContent> {
    switch (daoOrNull) {
      case (null) {
        let dao = Dao.Dao<Types.ProposalContent>(stableData.dao, onExecute, onReject);
        dao.resetEndTimers<system>(); // TODO move to inside DAO
        daoOrNull := ?dao;
        return dao;
      };
      case (?dao) dao;
    };
  };

  // var dao = Dao.Dao<Types.ProposalContent>(stableData.dao, onExecute, onReject);

  var scenarioVotingManager = ScenarioVoting.Manager(stableData.scenarioVoting);

  system func preupgrade() {
    let dao = getDao<system>();
    stableData := {
      scenarioVoting = scenarioVotingManager.toStableData();
      dao = dao.toStableData();
    };
  };

  system func postupgrade() {
    let dao = Dao.Dao<Types.ProposalContent>(stableData.dao, onExecute, onReject);
    dao.resetEndTimers<system>(); // TODO move to inside DAO
    daoOrNull := ?dao;
    scenarioVotingManager := ScenarioVoting.Manager(stableData.scenarioVoting);
  };

  public shared ({ caller }) func voteOnScenario(request : Types.VoteOnScenarioRequest) : async Types.VoteOnScenarioResult {
    let ?handler = scenarioVotingManager.getHandler(request.scenarioId) else return #scenarioNotFound;
    switch (await usersActor.get(caller)) {
      case (#ok(user)) {
        let ?team = user.team else return #notAuthorized;
        if (team.id != Principal.fromActor(this)) {
          return #notAuthorized;
        };
        let #owner(o) = team.kind else return #notAuthorized;
        handler.vote(caller, o.votingPower, request.option);
      };
      case (#notFound or #notAuthorized) #notAuthorized;
    };
  };

  public shared query ({ caller }) func getScenarioVote(request : Types.GetScenarioVoteRequest) : async Types.GetScenarioVoteResult {
    let ?handler = scenarioVotingManager.getHandler(request.scenarioId) else return #scenarioNotFound;
    #ok(handler.getVote(caller));
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
    let dao = getDao<system>();
    dao.createProposal<system>(caller, request.content, members);
  };

  public shared query func getProposal(id : Nat) : async ?Types.Proposal {
    switch (daoOrNull) {
      case (?dao) dao.getProposal(id);
      case (null) null;
    };
  };

  public shared query func getProposals() : async [Types.Proposal] {
    switch (daoOrNull) {
      case (?dao) dao.getProposals();
      case (null) [];
    };
  };

  public shared ({ caller }) func voteOnProposal(request : Types.VoteOnProposalRequest) : async Types.VoteOnProposalResult {
    let dao = getDao<system>();
    await* dao.vote(request.proposalId, caller, request.vote);
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
};
