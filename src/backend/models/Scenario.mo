import Skill "Skill";
import Nat "mo:base/Nat";
import Principal "mo:base/Principal";
import Text "mo:base/Text";
import Nat32 "mo:base/Nat32";
import Bool "mo:base/Bool";
import Trait "Trait";
import MatchAura "MatchAura";
import Team "Team";

module {

    public type ScenarioTeamIndex = Nat;
    public type ScenarioPlayerIndex = Nat;

    public type OtherTeam = {
        #opposingTeam;
        #otherTeam : ScenarioTeamIndex; // Teams are identified by the context order, 0 for first, 1 for second, etc.
    };

    public type Team = OtherTeam or {
        #scenarioTeam;
    };

    public type Target = {
        #league;
        #teams : [Team];
        #players : [ScenarioPlayerIndex]; // Players are identified by the context order, 0 for first, 1 for second, etc.
    };

    public type TargetInstance = {
        #league;
        #teams : [Principal];
        #players : [Nat32];
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
        #entropy : {
            team : Team;
            delta : Int;
        };
        #oneOf : [(Effect, Nat)]; // Weighted choices
        #allOf : [Effect];
        #noEffect;
    };

    public type TraitEffectOutcome = {
        target : TargetInstance;
        traitId : Text;
        duration : Duration;
    };

    public type EffectOutcome = {
        #trait : TraitEffectOutcome;
        #entropy : {
            teamId : Principal;
            delta : Int;
        };
    };

    public type ScenarioTeam = {
        // TODO other filters/weights
    };

    public type ScenarioPlayer = {
        team : Team;
        // TODO weights
    };

    public type ScenarioOption = {
        title : Text;
        description : Text;
        effect : Effect;
        // TODO optional requirements to unlock
        // TODO have option vote to be more for people who have the player favorited, and the player is doing something
    };

    public type Template = {
        id : Text;
        title : Text;
        description : Text;
        options : [ScenarioOption];
        otherTeams : [ScenarioTeam];
        players : [ScenarioPlayer];
        // TODO weights
    };

    public type Instance = {
        template : Template;
        teamId : Principal;
        opposingTeamId : Principal;
        otherTeamIds : [Principal];
        playerIds : [Nat32];
    };

    public type InstanceWithChoice = Instance and {
        choice : Nat8;
        effectOutcomes : [EffectOutcome];
    };

    public func hash(template : Template) : Nat32 = Text.hash(template.id);

    public func equal(a : Template, b : Template) : Bool = a.id == b.id;

    public func buildScenario(teamId : Principal, opposingTeamId : Principal) : Template = {
        id = "MYSTIC_PLAYBOOK_CONUNDRUM";
        title = "The Mystic Playbook Conundrum";
        description = "Amidst the ruins of an ancient sports complex, {Team0} uncovers the Mystic Playbook, said to be imbued with the wisdom of DAOball's greatest minds but rumored to be cursed.";
        teamId = teamId;
        opposingTeamId = opposingTeamId;
        otherTeams = [];
        players = [{
            team = #scenarioTeam;
        }];
        options = [
            {
                title = "Open for {Team0}";
                description = "{Team0} decides to brave the potential curse and gain strategic advantage by opening the Mystic Playbook themselves.";
                entropy = 10; // Reflects the chaos of risking a curse
                effect = #oneOf([
                    (
                        #trait({
                            target = #teams([#scenarioTeam]);
                            traitId = "CURSED";
                            duration = #indefinite;
                        }),
                        1,
                    ),
                    (
                        #trait({
                            target = #teams([#scenarioTeam]);
                            traitId = "ENHANCED";
                            duration = #matches(3); // Benefit for 3 matches if successful
                        }),
                        1,
                    ),
                ]);
            },
            {
                title = "Sell to {Team1}";
                description = "{Team0} sells the Mystic Playbook to {Team1}, transferring the risk of the curse and the chance of becoming rivals if {Team1} is afflicted.";
                entropy = -5; // Lower chaos due to transferring risk
                effect = #allOf([
                    // #currency({
                    //     target = #team(0);
                    //     amount = 100; // Team0 gains currency from the sale
                    // }),
                    #oneOf([
                        (
                            #allOf([
                                #trait({
                                    target = #teams([#opposingTeam]);
                                    traitId = "CURSED";
                                    duration = #indefinite;
                                }),
                                #trait({
                                    target = #teams([#scenarioTeam, #opposingTeam]);
                                    traitId = "RIVALS";
                                    duration = #indefinite;
                                }),
                            ]),
                            1 // 33% chance of activation
                        ),
                        (
                            #trait({
                                target = #teams([#opposingTeam]);
                                traitId = "ENHANCED";
                                duration = #matches(3); // Benefit for 3 matches if successful
                            }),
                            2 // 66% chance of activation
                        ),
                    ]),
                ]);
            },
            {
                title = "Secure and Research";
                description = "{Team0} secures the playbook and invests in researching it to mitigate the risk of the curse while attempting to unlock its secrets.";
                entropy = 0; // Neutral, as it's a balanced approach
                effect = #allOf([
                    #trait({
                        target = #teams([#scenarioTeam]);
                        traitId = "MODERATE_ENHANCEMENT";
                        duration = #matches(3); // Lesser benefit for 3 matches if successful
                    }),
                    #oneOf([
                        (
                            #trait({
                                target = #teams([#scenarioTeam]);
                                traitId = "MYSTIC_PLAYBOOK";
                                duration = #matches(1);
                            }),
                            4, // 80% chance of activation
                        ),
                        (
                            #noEffect,
                            1,
                        ),
                    ]),
                ]);
            },
        ];
    };

};
