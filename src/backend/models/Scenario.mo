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
        #oneOf : [(Nat, Effect)]; // Weighted choices
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
        effect : Effect;
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

};
