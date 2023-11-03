import Principal "mo:base/Principal";
import Trie "mo:base/Trie";
import TrieMap "mo:base/TrieMap";
import Hash "mo:base/Hash";
import Iter "mo:base/Iter";
module {

    public func trieToMap<T, K, N>(t : Trie.Trie<T, K>, equal : (T, T) -> Bool, hash : (T) -> Hash.Hash, mapFunc : (K) -> N) : TrieMap.TrieMap<T, N> {
        let entries = Trie.iter(t) |> Iter.map<(T, K), (T, N)>(_, func(x) { (x.0, mapFunc(x.1)) });
        TrieMap.fromEntries<T, N>(entries, equal, hash);
    };

    public func trieMapToTrie<T, K, N>(map : TrieMap.TrieMap<T, K>, equal : (T, T) -> Bool, hash : (T) -> Hash.Hash, mapFunc : (K) -> N) : Trie.Trie<T, N> {
        var trie = Trie.empty<T, N>();
        for (entry in map.entries()) {
            let key = {
                key = entry.0;
                hash = hash(entry.0);
            };
            let mappedValue = mapFunc(entry.1);
            let (newTrie, _) = Trie.put<T, N>(trie, key, equal, mappedValue);
            trie := newTrie;
        };
        trie;
    };
};
