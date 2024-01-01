import StadiumTypes "../stadium/Types";
import Buffer "mo:base/Buffer";
import Debug "mo:base/Debug";
import Trie "mo:base/Trie";
import Iter "mo:base/Iter";
import Offering "Offering";
import FieldPosition "FieldPosition";
import IterTools "mo:itertools/Iter";
import Skill "Skill";
import PseudoRandomX "mo:random/PseudoRandomX";
import Player "Player";
import Team "Team";
import MutableState "MutableState";

module {

    type Prng = PseudoRandomX.PseudoRandomGenerator;

    public type HookRequest<T> = {
        context : T;
        prng : Prng;
        state : MutableState.MutableMatchState;
    };

    public type HookResult<TContext> = {
        updatedContext : TContext;
    };

    public type CompiledHooks = {
        matchStart : Hook<()>;
        matchEnd : Hook<()>;
        roundStart : Hook<()>;
        roundEnd : Hook<()>;
        onDodge : Hook<SkillTestContext>;
        onPitch : Hook<SkillTestContext>;
        onSwing : Hook<SkillTestContext>;
        onHit : Hook<SkillTestContext>;
        onCatch : Hook<SkillTestContext>;
    };

    public type Hook<T> = (HookRequest<T>) -> HookResult<T>;

    public type SkillTestContext = {
        result : SkillTestResult;
        playerId : Player.PlayerId;
        skill : Skill.Skill;
    };

    public type SkillTestResult = {
        value : Int;
        crit : Bool;
    };

};
