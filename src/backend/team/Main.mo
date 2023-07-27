import Player "../Player";
import Principal "mo:base/Principal";
import Team "../Team";
import Trie "mo:base/Trie";
import Hash "mo:base/Hash";
import Nat32 "mo:base/Nat32";
import Debug "mo:base/Debug";
import Prelude "mo:base/Prelude";

actor class TeamActor(leagueId : Principal, initialPlayers : [Player.Player]) : async Team.TeamActor {

  module Util {

    public func buildKey(id : Nat32) : {
      key : Nat32;
      hash : Hash.Hash;
    } {
      { key = id; hash = id };
    };

    public func trieFromArray(players : [Player.Player]) : Trie.Trie<Nat32, Player.Player> {
      var trie : Trie.Trie<Nat32, Player.Player> = Trie.empty();
      for (player in players.vals()) {
        let key = buildKey(player.id);
        switch (Trie.put(trie, key, Nat32.equal, player)) {
          case (_, ?previous) {
            Debug.trap("Duplicate player id '" # Nat32.toText(player.id) # "'");
          };
          case (newTrie, null) {
            trie := newTrie;
          };
        };
      };
      trie;
    };

    public func validateCallerIsLeague(caller : Principal) {
      if (caller != leagueId) {
        Debug.trap("Only the league has access to this function");
      };
    };
  };

  stable var players : Trie.Trie<Nat32, Player.Player> = Util.trieFromArray(initialPlayers);

  public query func getPlayers() : async [Player.Player] {
    return Trie.toArray(players, func(k : Nat32, p : Player.Player) : Player.Player = p);
  };

  public shared ({ caller }) func addOrUpdatePlayer(player : Player.Player) : async {
    #ok;
  } {
    Util.validateCallerIsLeague(caller);
    let playerKey = Util.buildKey(player.id);
    let (newPlayers, _) = Trie.put(players, playerKey, Nat32.equal, player);

    players := newPlayers;
    #ok;
  };

  public shared ({ caller }) func removePlayer(id : Nat32) : async {
    #ok : Player.Player;
    #notFound;
  } {
    Util.validateCallerIsLeague(caller);
    let playerKey = Util.buildKey(id);
    switch (Trie.remove(players, playerKey, Nat32.equal)) {
      case (newPlayers, ?previous) {
        players := newPlayers;
        #ok(previous);
      };
      case (_, null) {
        #notFound;
      };
    };
  };

};
