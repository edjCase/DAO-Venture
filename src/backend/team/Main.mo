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
import { ic } "mo:ic";
import Stadium "../Stadium";
import IterTools "mo:itertools/Iter";

shared (install) actor class TeamActor(
  initLeagueId : Principal,
  initOwnerId : Principal,
) : async Team.TeamActor = this {

  type PlayerWithId = Player.PlayerWithId;
  type MatchOptionsCallback = Team.MatchOptionsCallback;
  type GetMatchOptionsResult = Team.GetMatchOptionsResult;
  type MatchOptions = Team.MatchOptions;
  type UpdateMatchOptionsResult = Team.UpdateMatchOptionsResult;
  type OfferingWithId = Stadium.OfferingWithId;
  type SpecialRuleWithId = Stadium.SpecialRuleWithId;
  type StadiumMatchId = Text; // Stadium Principal Text # _ # Match Id Text

  stable var leagueId = initLeagueId;
  stable var ownerId = initOwnerId;
  var matchOptions : Trie.Trie<StadiumMatchId, MatchOptions> = Trie.empty<StadiumMatchId, MatchOptions>();

  public composite query func getPlayers() : async [PlayerWithId] {
    let teamId = Principal.fromActor(this);
    await PlayerLedgerActor.getTeamPlayers(?teamId);
  };

  public shared ({ caller }) func updateMatchOptions(stadiumId : Principal, matchId : Nat32, options : MatchOptions) : async UpdateMatchOptionsResult {
    // TODO
    // assertOwner(caller);
    let stadiumActor = actor (Principal.toText(stadiumId)) : Stadium.StadiumActor;
    let match = try {
      let ?match = await stadiumActor.getMatch(matchId) else return #matchNotFound;
      match;
    } catch (err) {
      return #stadiumNotFound;
    };

    let teamId = Principal.fromActor(this);
    if (match.teams.0.id != teamId and match.teams.1.id != teamId) {
      return #teamNotInMatch;
    };

    let errors = Buffer.Buffer<Text>(0);
    let offeringExists = IterTools.any(match.offerings.vals(), func(o : OfferingWithId) : Bool = o.id == options.offeringId);
    if (not offeringExists) {
      errors.add("Invalid offering: " # Nat32.toText(options.offeringId));
    };
    for ((specialRuleId, votes) in Iter.fromArray(options.specialRuleVotes)) {
      let specialRuleExists = IterTools.any(match.specialRules.vals(), func(r : SpecialRuleWithId) : Bool = r.id == specialRuleId);
      if (match.specialRules.size() <= Nat32.toNat(specialRuleId)) {
        errors.add("Invalid special rule: " # Nat32.toText(specialRuleId));
      };
    };
    if (errors.size() > 0) {
      return #invalid(Buffer.toArray(errors));
    };
    let stadiumMatchId = buildStadiumMatchId(stadiumId, matchId);
    let matchKey = {
      key = stadiumMatchId;
      hash = Text.hash(stadiumMatchId);
    };
    let (newOptions, _) = Trie.put(
      matchOptions,
      matchKey,
      Text.equal,
      options,
    );
    matchOptions := newOptions;
    #ok;
  };

  public shared query ({ caller }) func getMatchOptions(stadiumId : Principal, matchId : Nat32) : async GetMatchOptionsResult {
    if (caller != stadiumId or caller != ownerId) {
      return #notAuthorized;
    };
    let stadiumMatchId = buildStadiumMatchId(stadiumId, matchId);
    let matchKey = {
      key = stadiumMatchId;
      hash = Text.hash(stadiumMatchId);
    };
    switch (Trie.get(matchOptions, matchKey, Text.equal)) {
      case (null) #noVotes;
      case (?o) #ok(o);
    };
  };

  public shared query ({ caller }) func getOwner() : async Principal {
    return ownerId;
  };

  public shared ({ caller }) func getCycles() : async Nat {
    assertOwner(caller);
    let canisterStatus = await ic.canister_status({
      canister_id = Principal.fromActor(this);
    });
    return canisterStatus.cycles;
  };

  private func buildStadiumMatchId(stadiumId : Principal, matchId : Nat32) : Text {
    Principal.toText(stadiumId) # "_" # Nat32.toText(matchId);
  };

  private func assertOwner(caller : Principal) {
    if (caller != ownerId) {
      Debug.trap("Caller is not the owner of the team");
    };
  };

};
