import Hash "mo:base/Hash";
import Player "../models/Player";
import Trie "mo:base/Trie";
import Nat32 "mo:base/Nat32";
import Debug "mo:base/Debug";

module Util {
    public func trieFromArray(players : [(Nat32, Player.Player)]) : Trie.Trie<Nat32, Player.Player> {
        var trie : Trie.Trie<Nat32, Player.Player> = Trie.empty();
        for ((id, player) in players.vals()) {
            let key = {
                key = id;
                hash = id;
            };
            switch (Trie.put(trie, key, Nat32.equal, player)) {
                case (_, ?previous) {
                    Debug.trap("Duplicate player id '" # Nat32.toText(id) # "'");
                };
                case (newTrie, null) {
                    trie := newTrie;
                };
            };
        };
        trie;
    };
};
