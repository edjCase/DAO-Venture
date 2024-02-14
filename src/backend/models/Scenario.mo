import Skill "Skill";
import Nat "mo:base/Nat";
import Principal "mo:base/Principal";
import Text "mo:base/Text";
import Nat32 "mo:base/Nat32";
import Bool "mo:base/Bool";
import Trait "Trait";
import MatchAura "MatchAura";

module {

    public type ScenarioTeamIndex = Nat;
    public type ScenarioPlayerIndex = Nat;

    public type Target = {
        #league;
        #teams : [ScenarioTeamIndex]; // Teams are identified by the context order, 0 for first, 1 for second, etc.
        #players : [ScenarioPlayerIndex]; // Players are identified by the context order, 0 for first, 1 for second, etc.
    };

    public type Duration = {
        #indefinite;
        #matches : Nat;
    };

    public type Effect = {
        #trait : {
            target : Target;
            traitId : Text;
            duration : Duration;
        };
        #alliance : (ScenarioTeamIndex, ScenarioTeamIndex);
        #rivalry : (ScenarioTeamIndex, ScenarioTeamIndex);
        #points : Int;
        #chance : {
            probability : Float;
            effects : [Effect];
        };
    };

    public type ScenarioTeam = {
        // TODO other filters/weights
    };

    public type ScenarioPlayer = {
        team : ScenarioTeamIndex;
        // TODO weights
    };

    public type ScenarioOption = {
        title : Text;
        description : Text;
        entropy : Int;
        effects : [Effect];
        // TODO optional requirements to unlock
        // TODO have option vote to be more for people who have the player favorited, and the player is doing something
    };

    public type Scenario = {
        id : Text;
        title : Text;
        teamId : Principal;
        opposingTeamId : Principal;
        description : Text;
        options : [ScenarioOption];
        otherTeams : [ScenarioTeam];
        players : [ScenarioPlayer];
        // TODO weights
    };

    public type Instance = {
        scenario : Scenario;
        otherTeamIds : [Principal];
        playerIds : [Nat32];
    };

    public type InstanceWithChoice = Instance and {
        choice : Nat8;
    };

    public func hash(scenario : Scenario) : Nat32 = Text.hash(scenario.id);

    public func equal(a : Scenario, b : Scenario) : Bool = a.id == b.id;

    public func buildScenario(teamId : Principal, opposingTeamId : Principal) : Scenario = {
        id = "MYSTIC_PLAYBOOK_CONUNDRUM";
        title = "The Mystic Playbook Conundrum";
        description = "Amidst the ruins of an ancient sports complex, {Team0} uncovers the Mystic Playbook, said to be imbued with the wisdom of DAOball's greatest minds but rumored to be cursed.";
        teamId = teamId;
        opposingTeamId = opposingTeamId;
        otherTeams = [];
        players = [{
            team = 0;
        }];
        options = [
            {
                title = "Open for {Team0}";
                description = "{Team0} decides to brave the potential curse and gain strategic advantage by opening the Mystic Playbook themselves.";
                entropy = 10; // Reflects the chaos of risking a curse
                effects = [
                    #trait({
                        target = #teams([0]);
                        traitId = "CURSED";
                        duration = #indefinite; // 50% chance of activation
                    }),
                ];
            },
            {
                title = "Sell to {Team1}";
                description = "{Team0} sells the Mystic Playbook to {Team1}, transferring the risk of the curse and the chance of becoming rivals if {Team1} is afflicted.";
                entropy = -5; // Lower chaos due to transferring risk
                effects = [
                    // #currency({
                    //     target = #team(0);
                    //     amount = 100; // Team0 gains currency from the sale
                    // }),
                    #chance({
                        probability = 0.3; // 30% chance of activation
                        effects = [
                            #trait({
                                target = #teams([1]);
                                traitId = "CURSED";
                                duration = #indefinite;
                            }),
                            #rivalry(0, 1),
                        ];
                    }),
                ];
            },
            {
                title = "Secure and Research";
                description = "{Team0} secures the playbook and invests in researching it to mitigate the risk of the curse while attempting to unlock its secrets.";
                entropy = 0; // Neutral, as it's a balanced approach
                effects = [
                    // #research({
                    //     target = #team(0);
                    //     topic = "MYSTIC_PLAYBOOK";
                    //     successRate = 80; // 20% chance of partial failure
                    // }),
                    #trait({
                        target = #teams([0]);
                        traitId = "MODERATE_ENHANCEMENT";
                        value = 10;
                        duration = #matches(3); // Lesser benefit for 3 matches if successful
                    }),
                ];
            },
        ];
    };

};
