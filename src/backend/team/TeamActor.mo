import Player "../Player";
import Principal "mo:base/Principal";
import Team "../Team";
import Trie "mo:base/Trie";
import Hash "mo:base/Hash";
import Nat32 "mo:base/Nat32";
import Debug "mo:base/Debug";
import Prelude "mo:base/Prelude";
import TeamUtil "TeamUtil";
import TrieSet "mo:base/TrieSet";
import PlayerLedgerActor "canister:playerLedger";
import Array "mo:base/Array";
import Buffer "mo:base/Buffer";
import Nat "mo:base/Nat";
import Error "mo:base/Error";
import Text "mo:base/Text";
import Iter "mo:base/Iter";
import None "mo:base/None";
import { ic } "mo:ic";
import Stadium "../Stadium";
import IterTools "mo:itertools/Iter";
import Types "mo:icrc1/ICRC1/Types";

shared (install) actor class TeamActor(
  initLeagueId : Principal,
  ledgerId : Principal,
) : async Team.TeamActor = this {

  type PlayerWithId = Player.PlayerWithId;
  type MatchOptionsCallback = Team.MatchOptionsCallback;
  type GetMatchOptionsResult = Team.GetMatchOptionsResult;
  type MatchOptions = Stadium.MatchOptions;
  type MatchOptionsVote = Team.MatchOptionsVote;
  type VoteForMatchOptionsResult = Team.VoteForMatchOptionsResult;
  type VoteForMatchOptionsRequest = Team.VoteForMatchOptionsRequest;
  type Offering = Stadium.Offering;
  type MatchAura = Stadium.MatchAura;
  type GetCyclesResult = Team.GetCyclesResult;
  type StadiumMatchId = Text; // Stadium Principal Text # _ # Match Id Text
  type PlayerId = Player.PlayerId;

  stable var leagueId = initLeagueId;
  var matchOptions : Trie.Trie<StadiumMatchId, Trie.Trie<Principal, MatchOptionsVote>> = Trie.empty();
  let ledger : Types.TokenInterface = actor (Principal.toText(ledgerId));

  public composite query func getPlayers() : async [PlayerWithId] {
    let teamId = Principal.fromActor(this);
    await PlayerLedgerActor.getTeamPlayers(?teamId);
  };

  public shared ({ caller }) func voteForMatchOptions(request : VoteForMatchOptionsRequest) : async VoteForMatchOptionsResult {
    let isOwner = await isTeamOwner(caller);
    if (not isOwner) {
      return #notAuthorized;
    };
    let stadiumActor = actor (Principal.toText(request.stadiumId)) : Stadium.StadiumActor;
    let match = try {
      let ?match = await stadiumActor.getMatch(request.matchId) else return #matchNotFound;
      match;
    } catch (err) {
      return #stadiumNotFound;
    };

    let teamId = Principal.fromActor(this);
    if (match.team1.id != teamId and match.team2.id != teamId) {
      return #teamNotInMatch;
    };

    let errors = Buffer.Buffer<Text>(0);
    let offeringExists = IterTools.any(match.offerings.vals(), func(o : Offering) : Bool = o == request.vote.offering);
    if (not offeringExists) {
      errors.add("Invalid offering: " # debug_show (request.vote.offering));
    };
    // TODO?
    // let championExists = IterTools.any(match.players.vals(), func(r : MatchAura) : Bool = r == request.vote.champion);
    // if (not championExists) {
    //   errors.add("Invalid champion: " # debug_show (request.vote.champion));
    // };
    if (errors.size() > 0) {
      return #invalid(Buffer.toArray(errors));
    };

    let stadiumMatchId = buildStadiumMatchId(request.stadiumId, request.matchId);
    let matchKey = {
      key = stadiumMatchId;
      hash = Text.hash(stadiumMatchId);
    };
    let matchVotes = switch (Trie.get(matchOptions, matchKey, Text.equal)) {
      case (null) Trie.empty();
      case (?o) o;
    };
    let voteKey = {
      key = caller;
      hash = Principal.hash(caller);
    };
    switch (Trie.put(matchVotes, voteKey, Principal.equal, request.vote)) {
      case ((_, ?existingVote)) #alreadyVoted;
      case ((newMatchVotes, null)) {
        // Add vote
        let (newOptions, _) = Trie.put(
          matchOptions,
          matchKey,
          Text.equal,
          newMatchVotes,
        );
        matchOptions := newOptions;
        #ok;
      };
    };
  };

  public shared query ({ caller }) func getMatchOptions(
    stadiumId : Principal,
    matchId : Nat32,
  ) : async GetMatchOptionsResult {
    if (caller != stadiumId and caller != leagueId) {
      return #notAuthorized;
    };
    let stadiumMatchId = buildStadiumMatchId(stadiumId, matchId);
    let matchKey = {
      key = stadiumMatchId;
      hash = Text.hash(stadiumMatchId);
    };
    switch (Trie.get(matchOptions, matchKey, Text.equal)) {
      case (null) #noVotes;
      case (?o) {
        let ?{ offering; champion } = calculateVotes(o) else return #noVotes;
        #ok({
          offering = offering;
          champion = champion;
        });
      };
    };
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

  public shared ({ caller }) func getLedgerId() : async Principal {
    return ledgerId;
  };

  private func calculateVotes(matchVotes : Trie.Trie<Principal, MatchOptionsVote>) : ?{
    offering : Offering;
    champion : PlayerId;
  } {
    var offeringVotes = Trie.empty<Offering, Nat>();
    var championVotes = Trie.empty<PlayerId, Nat>();
    for ((userId, vote) in Trie.iter(matchVotes)) {
      // Offering
      let userVotingPower = 1; // TODO
      let offeringKey = {
        key = vote.offering;
        hash = Stadium.hashOffering(vote.offering);
      };
      offeringVotes := addVotes(offeringVotes, offeringKey, Stadium.equalOffering, userVotingPower);
      let championKey = {
        key = vote.champion;
        hash = vote.champion;
      };
      championVotes := addVotes(championVotes, championKey, Nat32.equal, userVotingPower);
    };
    let ?winningOffering = calculateVote(offeringVotes) else return null;
    let ?winningChampion = calculateVote(championVotes) else return null;
    ?{
      offering = winningOffering;
      champion = winningChampion;
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
      case (?offering) ?offering.0;
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

  private func buildStadiumMatchId(stadiumId : Principal, matchId : Nat32) : Text {
    Principal.toText(stadiumId) # "_" # Nat32.toText(matchId);
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