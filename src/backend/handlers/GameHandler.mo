import WorldHandler "WorldHandler";
import ScenarioHandler "ScenarioHandler";
import CharacterHandler "CharacterHandler";
import PseudoRandomX "mo:xtended-random/PseudoRandomX";
import Debug "mo:base/Debug";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Nat32 "mo:base/Nat32";
import Iter "mo:base/Iter";
import Time "mo:base/Time";
import HashMap "mo:base/HashMap";
import Text "mo:base/Text";
import Trie "mo:base/Trie";
import Nat "mo:base/Nat";
import Array "mo:base/Array";
import Location "../models/Location";
import Scenario "../models/Scenario";
import Character "../models/Character";
import ExtendedProposal "mo:dao-proposal-engine/ExtendedProposal";
import IterTools "mo:itertools/Iter";
import CharacterGenerator "../CharacterGenerator";
import ScenarioSimulator "../ScenarioSimulator";
import Trait "../models/Trait";
import Item "../models/Item";
import Class "../models/Class";
import Race "../models/Race";
import Outcome "../models/Outcome";
import Image "../models/Image";

module {
    type Prng = PseudoRandomX.PseudoRandomGenerator;

    public type StableData = {
        current : GameInstance;
        historical : [CompletedData];
        classes : [Class.Class];
        races : [Race.Race];
        scenarios : [Scenario.ScenarioMetaData];
        items : [Item.Item];
        traits : [Trait.Trait];
        images : [Image.Image];
    };

    public type GameInstance = {
        #notInitialized;
        #notStarted : NotStartedData;
        #inProgress : InProgressData;
        #completed : CompletedData;
    };

    public type NotStartedData = {
        // Two proposals because i dont want the combo of character and difficulty, but rather the individual votes
        characterProposal : ExtendedProposal.Proposal<[Character.Character], Nat>;
        difficultyProposal : ExtendedProposal.Proposal<{}, Difficulty>;
    };

    public type InProgressData = {
        difficulty : Difficulty;
        world : WorldHandler.StableData;
        scenarios : ScenarioHandler.StableData;
        character : CharacterHandler.StableData;
    };

    public type CompletedData = {
        turns : Nat;
        difficulty : Difficulty;
        character : Character.Character;
    };

    public type Difficulty = {
        #easy;
        #medium;
        #hard;
    };

    public type GameInstanceWithMetaData = {
        #notInitialized;
        #notStarted : {
            characterOptions : [CharacterWithMetaData];
            characterVotes : ExtendedProposal.VotingSummary<Nat>;
            difficultyVotes : ExtendedProposal.VotingSummary<Difficulty>;
        };
        #inProgress : {
            turn : Nat;
            locations : [Location.Location];
            characterLocationId : Nat;
            character : CharacterWithMetaData;
        };
        #completed : {
            turns : Nat;
            difficulty : Difficulty;
            character : CharacterWithMetaData;
        };
    };

    public type CharacterWithMetaData = {
        health : Nat;
        gold : Nat;
        class_ : Class.Class;
        race : Race.Race;
        stats : Character.CharacterStats;
        items : [Item.Item];
        traits : [Trait.Trait];
    };

    public type ScenarioWithMetaData = Scenario.Scenario and {
        metaData : Scenario.ScenarioMetaData;
        availableChoiceIds : [Text];
    };

    type MutableGameInstance = {
        #notInitialized;
        #notStarted : MutableNotStartedData;
        #inProgress : MutableInProgressData;
        #completed : CompletedData;
    };

    type MutableNotStartedData = {
        var characterProposal : ExtendedProposal.Proposal<[Character.Character], Nat>;
        var difficultyProposal : ExtendedProposal.Proposal<{}, Difficulty>;
    };

    type MutableInProgressData = {
        difficulty : Difficulty;
        worldHandler : WorldHandler.Handler;
        scenarioHandler : ScenarioHandler.Handler;
        characterHandler : CharacterHandler.Handler;
    };

    public class Handler<system>(data : StableData) {
        var historical : [CompletedData] = data.historical;
        let classes = data.classes.vals()
        |> Iter.map<Class.Class, (Text, Class.Class)>(_, func(class_ : Class.Class) : (Text, Class.Class) = (class_.id, class_))
        |> HashMap.fromIter<Text, Class.Class>(_, data.classes.size(), Text.equal, Text.hash);

        let races = data.races.vals()
        |> Iter.map<Race.Race, (Text, Race.Race)>(_, func(race : Race.Race) : (Text, Race.Race) = (race.id, race))
        |> HashMap.fromIter<Text, Race.Race>(_, data.races.size(), Text.equal, Text.hash);

        let scenarios = data.scenarios.vals()
        |> Iter.map<Scenario.ScenarioMetaData, (Text, Scenario.ScenarioMetaData)>(_, func(scenario : Scenario.ScenarioMetaData) : (Text, Scenario.ScenarioMetaData) = (scenario.id, scenario))
        |> HashMap.fromIter<Text, Scenario.ScenarioMetaData>(_, data.scenarios.size(), Text.equal, Text.hash);

        let items = data.items.vals()
        |> Iter.map<Item.Item, (Text, Item.Item)>(_, func(item : Item.Item) : (Text, Item.Item) = (item.id, item))
        |> HashMap.fromIter<Text, Item.Item>(_, data.items.size(), Text.equal, Text.hash);

        let traits = data.traits.vals()
        |> Iter.map<Trait.Trait, (Text, Trait.Trait)>(_, func(trait : Trait.Trait) : (Text, Trait.Trait) = (trait.id, trait))
        |> HashMap.fromIter<Text, Trait.Trait>(_, data.traits.size(), Text.equal, Text.hash);

        let images = data.images.vals()
        |> Iter.map<Image.Image, (Text, Image.Image)>(_, func(image : Image.Image) : (Text, Image.Image) = (image.id, image))
        |> HashMap.fromIter<Text, Image.Image>(_, data.images.size(), Text.equal, Text.hash);

        var instance : MutableGameInstance = switch (data.current) {
            case (#notInitialized) #notInitialized;
            case (#notStarted(notStarted)) {
                #notStarted({
                    var characterProposal = notStarted.characterProposal;
                    var difficultyProposal = notStarted.difficultyProposal;
                });
            };
            case (#inProgress(inProgress)) {
                let worldHandler = WorldHandler.Handler(inProgress.world);
                let characterHandler = CharacterHandler.Handler(inProgress.character);
                let scenarioHandler = ScenarioHandler.Handler<system>(inProgress.scenarios);
                #inProgress({
                    difficulty = inProgress.difficulty;
                    worldHandler = worldHandler;
                    scenarioHandler = scenarioHandler;
                    characterHandler = characterHandler;
                });
            };
            case (#completed(completed)) #completed(completed);
        };

        public func toStableData() : StableData {
            let current = fromMutableInstance(instance);
            {
                current;
                historical;
                classes = Iter.toArray(classes.vals());
                races = Iter.toArray(races.vals());
                scenarios = Iter.toArray(scenarios.vals());
                items = Iter.toArray(items.vals());
                traits = Iter.toArray(traits.vals());
                images = Iter.toArray(images.vals());
            };
        };

        public func initialize(
            prng : Prng,
            proposerId : Principal,
            members : [ExtendedProposal.Member],
        ) : Result.Result<(), { #alreadyInitialized; #noClasses; #noRaces; #noScenarios; #noItems; #noTraits; #noImages }> {
            let #notInitialized = instance else return #err(#alreadyInitialized);
            if (classes.size() == 0) {
                return #err(#noClasses);
            };
            if (races.size() == 0) {
                return #err(#noRaces);
            };
            if (scenarios.size() == 0) {
                return #err(#noScenarios);
            };
            if (items.size() == 0) {
                return #err(#noItems);
            };
            if (traits.size() == 0) {
                return #err(#noTraits);
            };
            if (images.size() == 0) {
                return #err(#noImages);
            };
            let classArray = Iter.toArray(classes.vals());
            let raceArray = Iter.toArray(races.vals());
            let characterOptions = IterTools.range(0, 4)
            |> Iter.map(
                _,
                func(_ : Nat) : Character.Character {
                    let class_ = prng.nextArrayElement(classArray);
                    let race = prng.nextArrayElement(raceArray);
                    CharacterGenerator.generate(class_, race);
                },
            )
            |> Iter.toArray(_);

            let timeStart = Time.now();
            let timeEnd : ?Time.Time = null;

            instance := #notStarted({
                var characterProposal = ExtendedProposal.create(0, proposerId, characterOptions, members, timeStart, timeEnd);
                var difficultyProposal = ExtendedProposal.create(0, proposerId, {}, members, timeStart, timeEnd);
            });
            #ok;
        };

        public func getScenario(scenarioId : Nat) : Result.Result<ScenarioWithMetaData, { #noActiveGame; #notFound }> {
            let #inProgress({ scenarioHandler; characterHandler }) = instance else return #err(#noActiveGame);
            let ?scenario = scenarioHandler.get(scenarioId) else return #err(#notFound);
            let character = characterHandler.get();
            #ok(mapScenario(scenario, character));
        };

        public func getScenarios() : Result.Result<[ScenarioWithMetaData], { #noActiveGame }> {
            let #inProgress({ scenarioHandler; characterHandler }) = instance else return #err(#noActiveGame);
            let character = characterHandler.get();
            let scenariosWithMetaData = scenarioHandler.getAll().vals()
            |> Iter.map<ScenarioHandler.ScenarioInstance, ScenarioWithMetaData>(
                _,
                func(scenario : ScenarioHandler.ScenarioInstance) : ScenarioWithMetaData = mapScenario(scenario, character),
            )
            |> Iter.toArray(_);
            #ok(scenariosWithMetaData);
        };

        public func voteOnScenario(
            scenarioId : Nat,
            voterId : Principal,
            choiceId : Text,
        ) : Result.Result<?Text, ScenarioHandler.VoteError or { #noActiveGame; #choiceRequirementNotMet }> {
            let #inProgress({ scenarioHandler; characterHandler }) = instance else return #err(#noActiveGame);
            let ?scenario = scenarioHandler.get(scenarioId) else return #err(#scenarioNotFound);
            let ?scenarioMetaData = scenarios.get(scenario.metaDataId) else Debug.trap("Scenario meta data not found: " # scenario.metaDataId);
            let ?choice = Array.find(
                scenarioMetaData.choices,
                func(choice : Scenario.Choice) : Bool = choiceId == choice.id,
            ) else return #err(#invalidChoice);
            switch (choice.requirement) {
                case (null) ();
                case (?requirement) {
                    let character = characterHandler.get();
                    if (not Outcome.validateRequirement(requirement, character)) {
                        return #err(#choiceRequirementNotMet);
                    };
                };
            };

            scenarioHandler.vote(scenarioId, voterId, choiceId);
        };

        public func getScenarioVote(scenarioId : Nat, voterId : Principal) : Result.Result<ExtendedProposal.Vote<Text>, { #scenarioNotFound; #notEligible; #noActiveGame }> {
            let #inProgress({ scenarioHandler }) = instance else return #err(#noActiveGame);
            scenarioHandler.getVote(scenarioId, voterId);
        };

        public func getScenarioVoteSummary(scenarioId : Nat) : Result.Result<ExtendedProposal.VotingSummary<Text>, { #scenarioNotFound; #noActiveGame }> {
            let #inProgress({ scenarioHandler }) = instance else return #err(#noActiveGame);
            scenarioHandler.getVoteSummary(scenarioId);
        };

        public func voteOnNewGame(
            voterId : Principal,
            characterId : Nat,
            difficulty : Difficulty,
        ) : Result.Result<?{ characterId : Nat; difficulty : Difficulty }, ExtendedProposal.VoteError or { #noActiveGame; #invalidCharacterId }> {
            let #notStarted(notStarted) = instance else return #err(#noActiveGame);

            if (characterId >= notStarted.characterProposal.content.size()) {
                return #err(#invalidCharacterId);
            };
            let updatedCharacterProposal = switch (ExtendedProposal.vote(notStarted.characterProposal, voterId, characterId)) {
                case (#ok(ok)) ok.updatedProposal;
                case (#err(error)) return #err(error);
            };
            let updatedDifficultyProposal = switch (ExtendedProposal.vote(notStarted.difficultyProposal, voterId, difficulty)) {
                case (#ok(ok)) ok.updatedProposal;
                case (#err(error)) return #err(error);
            };
            // Dont set unless both votes are successful
            notStarted.characterProposal := updatedCharacterProposal;
            notStarted.difficultyProposal := updatedDifficultyProposal;

            let votingThreshold : ExtendedProposal.VotingThreshold = #percent({
                percent = 50;
                quorum = null;
            });
            let characterIdOrNull : ?Nat = switch (
                ExtendedProposal.calculateVoteStatus(
                    notStarted.characterProposal,
                    votingThreshold,
                    equalNat,
                    Nat32.fromNat,
                    false,
                )
            ) {
                case (#determined(characterIdOrNull)) characterIdOrNull;
                case (#undetermined) null;
            };
            let chosenCharacterId : Nat = switch (characterIdOrNull) {
                case (?id) id;
                case (null) return #ok(null); // Vote still in progress
            };

            let difficultyOrNull : ?Difficulty = switch (
                ExtendedProposal.calculateVoteStatus(
                    notStarted.difficultyProposal,
                    votingThreshold,
                    difficultyEqual,
                    difficultyHash,
                    false,
                )
            ) {
                case (#determined(difficultyOrNull)) difficultyOrNull;
                case (#undetermined) null;
            };

            let chosenDifficulty : Difficulty = switch (difficultyOrNull) {
                case (?d) d;
                case (null) return #ok(null); // Vote still in progress
            };
            #ok(
                ?{
                    characterId = chosenCharacterId;
                    difficulty = chosenDifficulty;
                }
            );
        };

        public func startGame<system>(
            prng : Prng,
            characterId : Nat,
            proposerId : Principal,
            difficulty : Difficulty,
            members : [ScenarioHandler.Member],
        ) : Result.Result<(), { #alreadyStarted }> {
            let #notStarted(notStarted) = instance else return #err(#alreadyStarted);
            let character = notStarted.characterProposal.content[characterId];

            let characterHandler = CharacterHandler.Handler({
                character = character;
            });
            let scenarioHandler = ScenarioHandler.Handler<system>({
                instances = [];
                metaDataList = [];
            });
            let scenario = generateScenario(prng);
            let scenarioId = scenarioHandler.start(scenario, proposerId, members);
            let location : Location.Location = {
                id = 0;
                coordinate = { q = 0; r = 0 };
                scenarioId = scenarioId;
            };
            let worldHandler = WorldHandler.Handler({
                characterLocationId = 0;
                turn = 0;
                locations = [location];
            });
            instance := #inProgress({
                difficulty;
                worldHandler = worldHandler;
                scenarioHandler = scenarioHandler;
                characterHandler = characterHandler;
            });
            #ok;
        };

        public func endTurn(
            prng : Prng,
            proposerId : Principal,
            members : [ScenarioHandler.Member],
            choiceOrUndecided : ?Text,
        ) : Result.Result<(), { #noActiveGame }> {
            let #inProgress({ worldHandler; scenarioHandler; characterHandler }) = instance else return #err(#noActiveGame);

            let scenarioId = worldHandler.getCharacterLocation().scenarioId;

            let ?scenario = scenarioHandler.get(scenarioId) else Debug.trap("Scenario not found: " # Nat.toText(scenarioId));
            let ?scenarioMetaData = scenarios.get(scenario.metaDataId) else Debug.trap("Scenario meta data not found: " # scenario.metaDataId);

            let outcome = ScenarioSimulator.run(
                prng,
                characterHandler,
                scenario,
                scenarioMetaData,
                choiceOrUndecided,
            );
            switch (scenarioHandler.end(scenarioId, outcome)) {
                case (#ok) ();
                case (#err(error)) Debug.trap("Unable to end scenario: " # debug_show (error));
            };
            let newScenario = generateScenario(prng);
            let newScenarioId = scenarioHandler.start(newScenario, proposerId, members);
            worldHandler.nextTurn(newScenarioId);
            #ok;
        };

        public func getInstance() : GameInstanceWithMetaData {
            toInstanceWithMetaData(instance);
        };

        public func addItem(item : Item.Item) : Result.Result<(), { #invalid : [Text] }> {
            switch (Item.validate(item, items)) {
                case (#err(errors)) return #err(#invalid(errors));
                case (#ok) ();
            };
            Debug.print("Adding item: " # item.id);
            items.put(item.id, item);
            #ok;
        };

        public func addTrait(trait : Trait.Trait) : Result.Result<(), { #invalid : [Text] }> {
            switch (Trait.validate(trait, traits)) {
                case (#err(errors)) return #err(#invalid(errors));
                case (#ok) ();
            };
            Debug.print("Adding trait: " # trait.id);
            traits.put(trait.id, trait);
            #ok;
        };

        public func addRace(race : Race.Race) : Result.Result<(), { #invalid : [Text] }> {
            switch (Race.validate(race, races, items, traits)) {
                case (#err(errors)) return #err(#invalid(errors));
                case (#ok) ();
            };
            Debug.print("Adding race: " # race.id);
            races.put(race.id, race);
            #ok;
        };

        public func addClass(class_ : Class.Class) : Result.Result<(), { #invalid : [Text] }> {
            switch (Class.validate(class_, classes, items, traits)) {
                case (#err(errors)) return #err(#invalid(errors));
                case (#ok) ();
            };
            Debug.print("Adding class: " # class_.id);
            classes.put(class_.id, class_);
            #ok;
        };

        public func addScenarioMetaData(scenario : Scenario.ScenarioMetaData) : Result.Result<(), { #invalid : [Text] }> {
            switch (
                Scenario.validateMetaData(
                    scenario,
                    scenarios,
                    items,
                    traits,
                    images,
                )
            ) {
                case (#err(errors)) return #err(#invalid(errors));
                case (#ok) ();
            };
            Debug.print("Adding scenario meta data: " # scenario.id);
            scenarios.put(scenario.id, scenario);
            #ok;
        };

        public func addImage(image : Image.Image) : Result.Result<(), { #invalid : [Text] }> {
            switch (Image.validate(image, images)) {
                case (#err(errors)) return #err(#invalid(errors));
                case (#ok) ();
            };

            Debug.print("Adding image: " # image.id);
            images.put(image.id, image);
            #ok;
        };

        public func getImage(imageId : Text) : ?Image.Image {
            images.get(imageId);
        };

        private func mapScenario(
            scenario : ScenarioHandler.ScenarioInstance,
            character : Character.Character,
        ) : ScenarioWithMetaData {
            let ?metaData = scenarios.get(scenario.metaDataId) else Debug.trap("Scenario meta data not found: " # scenario.metaDataId);
            {
                scenario with
                metaData = metaData;
                availableChoiceIds = metaData.choices.vals()
                |> Iter.filter(
                    _,
                    func(choice : Scenario.Choice) : Bool {
                        switch (choice.requirement) {
                            case (null) true;
                            case (?requirement) Outcome.validateRequirement(requirement, character);
                        };
                    },
                )
                |> Iter.map(_, func(choice : Scenario.Choice) : Text = choice.id)
                |> Iter.toArray(_);
            };
        };

        private func generateScenario(prng : Prng) : {
            metaDataId : Text;
            data : [Scenario.GeneratedDataFieldInstance];
        } {
            let scenarioMetaData = prng.nextArrayElement(Iter.toArray(scenarios.vals()));
            let scenarioData = scenarioMetaData.data.vals()
            |> Iter.map<Scenario.GeneratedDataField, Scenario.GeneratedDataFieldInstance>(
                _,
                func(field : Scenario.GeneratedDataField) : Scenario.GeneratedDataFieldInstance {
                    let value = switch (field.value) {
                        case (#nat({ min; max })) #nat(prng.nextNat(min, max));
                        case (#text(text)) #text(prng.nextArrayElementWeighted(text.options));
                    };
                    {
                        id = field.id;
                        value = value;
                    };
                },
            )
            |> Iter.toArray(_);
            {
                metaDataId = scenarioMetaData.id;
                data = scenarioData;
            };
        };

        private func toInstanceWithMetaData(instance : MutableGameInstance) : GameInstanceWithMetaData {
            switch (instance) {
                case (#notInitialized) #notInitialized;
                case (#notStarted(notStarted)) {
                    let characterVotes = ExtendedProposal.buildVotingSummary(notStarted.characterProposal, equalNat, Nat32.fromNat);
                    let difficultyVotes = ExtendedProposal.buildVotingSummary(notStarted.difficultyProposal, difficultyEqual, difficultyHash);
                    #notStarted({
                        characterOptions = notStarted.characterProposal.content.vals() |> Iter.map(_, toCharacterWithMetaData) |> Iter.toArray(_);
                        characterVotes;
                        difficultyVotes;
                    });
                };
                case (#inProgress(inProgress)) {
                    let turn = inProgress.worldHandler.getTurn();
                    let locations = inProgress.worldHandler.getLocations();
                    let characterLocationId = inProgress.worldHandler.getCharacterLocation().id;
                    let character = toCharacterWithMetaData(inProgress.characterHandler.get());
                    #inProgress({
                        turn;
                        locations;
                        characterLocationId;
                        character;
                    });
                };
                case (#completed(completed)) {
                    let turns = completed.turns;
                    let difficulty = completed.difficulty;
                    let character = toCharacterWithMetaData(completed.character);
                    #completed({ turns; difficulty; character });
                };
            };
        };

        private func toCharacterWithMetaData(
            character : Character.Character
        ) : CharacterWithMetaData {
            let ?class_ = classes.get(character.classId) else Debug.trap("Class not found: " # character.classId);
            let ?race = races.get(character.raceId) else Debug.trap("Race not found: " # character.raceId);
            let itemsWithMetaData = Trie.iter(character.itemIds)
            |> Iter.map(
                _,
                func((itemId, _) : (Text, ())) : Item.Item {
                    let ?item = items.get(itemId) else Debug.trap("Item not found: " # itemId);
                    item;
                },
            )
            |> Iter.toArray(_);

            let traitsWithMetaData = Trie.iter(character.traitIds)
            |> Iter.map(
                _,
                func((traitId, _) : (Text, ())) : Trait.Trait {
                    let ?trait = traits.get(traitId) else Debug.trap("Trait not found: " # traitId);
                    trait;
                },
            )
            |> Iter.toArray(_);
            {
                health = character.health;
                gold = character.gold;
                class_ = class_;
                race = race;
                stats = character.stats;
                items = itemsWithMetaData;
                traits = traitsWithMetaData;
            };
        };

    };

    private func fromMutableInstance(instance : MutableGameInstance) : GameInstance {
        switch (instance) {
            case (#notInitialized) #notInitialized;
            case (#notStarted(notStarted)) {
                #notStarted({
                    characterProposal = notStarted.characterProposal;
                    difficultyProposal = notStarted.difficultyProposal;
                });
            };
            case (#inProgress(inProgress)) {
                #inProgress({
                    difficulty = inProgress.difficulty;
                    world = inProgress.worldHandler.toStableData();
                    scenarios = inProgress.scenarioHandler.toStableData();
                    character = inProgress.characterHandler.toStableData();
                });
            };
            case (#completed(completed)) #completed(completed);
        };
    };

    private func equalNat(a : Nat, b : Nat) : Bool {
        a == b;
    };

    private func difficultyEqual(a : Difficulty, b : Difficulty) : Bool {
        a == b;
    };

    private func difficultyHash(difficulty : Difficulty) : Nat32 {
        switch (difficulty) {
            case (#easy) 0;
            case (#medium) 1;
            case (#hard) 2;
        };
    };
};
