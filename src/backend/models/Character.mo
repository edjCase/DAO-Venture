import TrieSet "mo:base/TrieSet";
import Text "mo:base/Text";
import Buffer "mo:base/Buffer";
import HashMap "mo:base/HashMap";
import Debug "mo:base/Debug";
import PseudoRandomX "mo:xtended-random/PseudoRandomX";
import Class "entities/Class";
import Race "entities/Race";
import Weapon "entities/Weapon";

module {
    type Prng = PseudoRandomX.PseudoRandomGenerator;

    public type Character = {
        health : Nat;
        maxHealth : Nat;
        gold : Nat;
        classId : Text;
        raceId : Text;
        weaponId : Text;
        itemIds : TrieSet.Set<Text>;
    };

    public func getActionIds(
        character : Character,
        classes : HashMap.HashMap<Text, Class.Class>,
        races : HashMap.HashMap<Text, Race.Race>,
        weapons : HashMap.HashMap<Text, Weapon.Weapon>,
    ) : Buffer.Buffer<Text> {
        let allActionIds = Buffer.Buffer<Text>(10);

        let ?class_ = classes.get(character.classId) else Debug.trap("Class not found: " # character.classId);
        allActionIds.append(Buffer.fromArray(class_.actionIds));

        let ?race = races.get(character.raceId) else Debug.trap("Race not found: " # character.raceId);
        allActionIds.append(Buffer.fromArray(race.actionIds));

        let ?weapon = weapons.get(character.weaponId) else Debug.trap("Weapon not found: " # character.weaponId);
        allActionIds.append(Buffer.fromArray(weapon.actionIds));

        // TODO?
        // let traitActionIds = Trie.iter(character.traitIds)
        // |> Iter.map<(Text, ()), Iter.Iter<Text>>(
        //     _,
        //     func((traitId, _) : (Text, ())) : Iter.Iter<Text> {
        //         let ?trait = traits.get(traitId) else Debug.trap("Trait not found: " # traitId);
        //         trait.actionIds.vals();
        //     },
        // )
        // |> IterTools.flatten(_);
        // allActionIds.append(Buffer.fromArray(traitActionIds));

        allActionIds;
    };
};
