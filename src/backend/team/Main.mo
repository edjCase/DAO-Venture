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
import { ic } "mo:ic";
import Stadium "../Stadium";

shared (install) actor class TeamActor(leagueId : Principal, ownerId : Principal) : async Team.TeamActor = this {
  type PlayerWithId = Player.PlayerWithId;

  var players : TrieSet.Set<Nat32> = TrieSet.empty();

  public composite query func getPlayers() : async [PlayerWithId] {
    let teamId = Principal.fromActor(this);
    await PlayerLedgerActor.getTeamPlayers(?teamId);
  };

  public shared ({ caller }) func getOwner() : async Principal {
    return ownerId;
  };

  public shared ({ caller }) func getCycles() : async Nat {
    assertOwner(caller);
    let canisterStatus = await ic.canister_status({
      canister_id = Principal.fromActor(this);
    });
    return canisterStatus.cycles;
  };

  public shared ({ caller }) func registerForMatch(
    stadiumId : Principal,
    matchId : Nat32,
    registrationInfo : Stadium.MatchRegistrationInfo,
  ) : async Stadium.RegisterResult {
    assertOwner(caller);
    let stadiumActor = actor (Principal.toText(stadiumId)) : Stadium.StadiumActor;
    await stadiumActor.registerForMatch(matchId, registrationInfo);
  };

  private func assertOwner(caller : Principal) {
    if (caller != ownerId) {
      Debug.trap("Caller is not the owner of the team");
    };
  };

};
