import Player "../models/Player";
import Principal "mo:base/Principal";
import Team "../models/Team";
import Trie "mo:base/Trie";
import Hash "mo:base/Hash";
import Nat32 "mo:base/Nat32";
import Debug "mo:base/Debug";
import Prelude "mo:base/Prelude";
import TrieSet "mo:base/TrieSet";
import Array "mo:base/Array";
import Buffer "mo:base/Buffer";
import Nat "mo:base/Nat";
import Error "mo:base/Error";
import Text "mo:base/Text";
import Iter "mo:base/Iter";
import None "mo:base/None";
import HashMap "mo:base/HashMap";
import StadiumTypes "../stadium/Types";
import PlayersTypes "../players/Types";
import IterTools "mo:itertools/Iter";
import LeagueTypes "../league/Types";
import Types "Types";
import MatchAura "../models/MatchAura";
import Season "../models/Season";
import Util "../Util";
import Scenario "../models/Scenario";
import TeamState "./TeamState";
import Dao "../Dao";

module {
    type MemberWithoutId = {
        votingPower : Nat;
    };

    public type Member = MemberWithoutId and {
        id : Principal;
    };

    public type Data = {
        members : [Member];
    };

    public class TeamDao(data : Data) {
        let membersIter = data.members.vals()
        |> Iter.map<Member, (Principal, MemberWithoutId)>(
            _,
            func(member : Member) : (Principal, MemberWithoutId) = (member.id, member),
        );
        var members = HashMap.fromIter<Principal, MemberWithoutId>(membersIter, data.members.size(), Principal.equal, Principal.hash);

        public func getMember(id : Principal) : ?Member {
            let ?member = members.get(id) else return null;
            ?{
                member with
                id = id;
            };
        };

        public func addMember(id : Principal, member : MemberWithoutId) : {
            #ok;
            #alreadyExists;
        } {
            let null = members.get(id) else return #alreadyExists;
            members.put(id, member);
            #ok;
        };

        public func toData() : Data {
            let membersArray = members.entries()
            |> Iter.map(
                _,
                func((k, v) : (Principal, MemberWithoutId)) : Member {
                    {
                        v with
                        id = k;
                    };
                },
            )
            |> Iter.toArray(_);

            {
                members = membersArray;
            };
        };
    };
};
