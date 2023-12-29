import StadiumTypes "Types";
import Hook "../models/Hook";
import Offering "../models/Offering";
import Team "../models/Team";
import MutableState "../models/MutableState";
import PseudoRandomX "mo:random/PseudoRandomX";
import Buffer "mo:base/Buffer";
import Iter "mo:base/Iter";
import TrieSet "mo:base/TrieSet";
import Nat32 "mo:base/Nat32";
import Option "mo:base/Option";
import FieldPosition "../models/FieldPosition";
import Player "../models/Player";
import Skill "../models/Skill";

module {
    type Prng = PseudoRandomX.PseudoRandomGenerator;

    public type PreCompiledHooks = {
        matchStart : ?Hook.Hook<()>;
        matchEnd : ?Hook.Hook<()>;
        roundStart : ?Hook.Hook<()>;
        roundEnd : ?Hook.Hook<()>;
        onDodge : ?Hook.Hook<Hook.SkillTestContext>;
        onPitch : ?Hook.Hook<Hook.SkillTestContext>;
    };

    public func compile(state : StadiumTypes.InProgressMatch) : Hook.CompiledHooks {
        let allHooks = [
            fromOffering(state.team1.offering, #team1),
            fromOffering(state.team2.offering, #team2),
            // fromAura(state.aura)
        ];

        var matchStart : ?Hook.Hook<()> = null;
        var matchEnd : ?Hook.Hook<()> = null;
        var roundStart : ?Hook.Hook<()> = null;
        var roundEnd : ?Hook.Hook<()> = null;
        var onDodge : ?Hook.Hook<Hook.SkillTestContext> = null;
        var onPitch : ?Hook.Hook<Hook.SkillTestContext> = null;
        for (hook in Iter.fromArray(allHooks)) {
            matchStart := mergeHook(matchStart, hook.matchStart);
            matchEnd := mergeHook(matchEnd, hook.matchEnd);
            roundStart := mergeHook(roundStart, hook.roundStart);
            roundEnd := mergeHook(roundEnd, hook.roundEnd);
            onDodge := mergeHook(onDodge, hook.onDodge);
            onPitch := mergeHook(onPitch, hook.onPitch);
        };
        // If there's no hook, then just return an empty hook
        let hookOrEmpty = func<T>(hook : ?Hook.Hook<T>) : Hook.Hook<T> {
            switch (hook) {
                case (null) func(request : Hook.HookRequest<T>) : Hook.HookResult<T> {
                    {
                        updatedContext = request.context;
                    };
                };
                case (?h) h;
            };
        };
        {
            matchStart = hookOrEmpty(matchStart);
            matchEnd = hookOrEmpty(matchEnd);
            roundStart = hookOrEmpty(roundStart);
            roundEnd = hookOrEmpty(roundEnd);
            onDodge = hookOrEmpty(onDodge);
            onPitch = hookOrEmpty(onPitch);
        };
    };

    private func mergeHook<T>(hook1 : ?Hook.Hook<T>, hook2 : ?Hook.Hook<T>) : ?Hook.Hook<T> {
        switch (hook1, hook2) {
            case (null, null) return null;
            case (null, ?h2) return ?h2; // If no previous hook, then make only hook
            case (?h1, null) return ?h1; // If no new hook, then keep old hook
            case (?h1, ?h2) {
                // call h1, then h2
                return ?(
                    func(request : Hook.HookRequest<T>) : Hook.HookResult<T> {
                        // TODO callback
                        let result1 = h1(request);
                        let request2 = {
                            context = result1.updatedContext;
                        };
                        let result2 = h2(request);
                        {
                            updatedContext = result2.updatedContext;
                        };
                    }
                );
            };
        };
    };

    public func fromOffering(offering : Offering.Offering, teamId : Team.TeamId) : PreCompiledHooks {
        switch (offering) {
            case (#shuffleAndBoost) shuffleAndBoostHook(teamId);
            case (#offensive) offensiveHook(teamId);
            case (#defensive) defensiveHook(teamId);
            case (#hittersDebt) hittersDebtHook(teamId);
            case (#ragePitch) ragePitchHook(teamId);
            case (#bubble) bubbleHook(teamId);
            // case (#underdog) underdogHook(teamId);
            // case (#pious) piousHook(teamId);
            // case (#confident) confidentHook(teamId);
            // case (#moraleFlywheel) moraleFlywheelHook(teamId);
        };
    };

    private func shuffleAndBoostHook(teamId : Team.TeamId) : PreCompiledHooks {
        let matchStartHook = func(request : Hook.HookRequest<()>) : Hook.HookResult<()> {
            // Shuffle all the players' positions but boost their stats
            var teamPlayers : Buffer.Buffer<(Player.PlayerId, MutableState.MutablePlayerState)> = Buffer.fromIter(request.state.getTeamPlayers(teamId));

            let currentPositions : Buffer.Buffer<FieldPosition.FieldPosition> = teamPlayers
            |> Buffer.map(
                _,
                func(p : (Player.PlayerId, MutableState.MutablePlayerState)) : FieldPosition.FieldPosition = p.1.position,
            );
            request.prng.shuffleBuffer(currentPositions);
            let randomSkill = Skill.getRandom(request.prng);
            var i = 0;
            for ((playerId, playerState) in teamPlayers.vals()) {
                MutableState.modifyPlayerSkill(playerState.skills, randomSkill, 1);
                playerState.position := currentPositions.get(i);
                i += 1;
            };
            {
                updatedContext = ();
            };
        };
        {
            matchStart = ?matchStartHook;
            matchEnd = null;
            roundStart = null;
            roundEnd = null;
            onDodge = null;
            onPitch = null;
        };
    };

    private func offensiveHook(teamId : Team.TeamId) : PreCompiledHooks {
        let matchStartHook = func(request : Hook.HookRequest<()>) : Hook.HookResult<()> {
            // Increase batting power and lower catching
            for ((playerId, playerState) in request.state.getTeamPlayers(teamId)) {
                MutableState.modifyPlayerSkill(playerState.skills, #battingPower, 1);
                MutableState.modifyPlayerSkill(playerState.skills, #catching, -1);
            };
            {
                updatedContext = ();
            };
        };
        {
            matchStart = ?matchStartHook;
            matchEnd = null;
            roundStart = null;
            roundEnd = null;
            onDodge = null;
            onPitch = null;
        };
    };

    private func defensiveHook(teamId : Team.TeamId) : PreCompiledHooks {
        let matchStartHook = func(request : Hook.HookRequest<()>) : Hook.HookResult<()> {
            // Increase catching and lower batting power
            for ((playerId, playerState) in request.state.getTeamPlayers(teamId)) {
                MutableState.modifyPlayerSkill(playerState.skills, #catching, 1);
                MutableState.modifyPlayerSkill(playerState.skills, #battingPower, -1);
            };
            {
                updatedContext = ();
            };
        };
        {
            matchStart = ?matchStartHook;
            matchEnd = null;
            roundStart = null;
            roundEnd = null;
            onDodge = null;
            onPitch = null;
        };
    };

    private func hittersDebtHook(teamId : Team.TeamId) : PreCompiledHooks {
        let matchStartHook = func(request : Hook.HookRequest<()>) : Hook.HookResult<()> {
            switch (teamId) {
                case (#team1) {
                    request.state.team1.score -= 1;
                };
                case (#team2) {
                    request.state.team2.score -= 1;
                };
            };
            {
                updatedContext = ();
            };
        };
        {
            matchStart = ?matchStartHook;
            matchEnd = null;
            roundStart = null;
            roundEnd = null;
            onDodge = null;
            onPitch = null;
        };
    };

    private func ragePitchHook(teamId : Team.TeamId) : PreCompiledHooks {
        let matchStartHook = func(request : Hook.HookRequest<()>) : Hook.HookResult<()> {
            // Increase throwing power and lower throwing accuracy for pitchers
            label f for ((playerId, playerState) in request.state.getTeamPlayers(teamId)) {
                if (playerState.position != #pitcher) {
                    continue f;
                };
                MutableState.modifyPlayerSkill(playerState.skills, #throwingPower, 1);
                MutableState.modifyPlayerSkill(playerState.skills, #throwingAccuracy, -1);
            };
            {
                updatedContext = ();
            };
        };
        {
            matchStart = ?matchStartHook;
            matchEnd = null;
            roundStart = null;
            roundEnd = null;
            onDodge = null;
            onPitch = null;
        };
    };

    private func bubbleHook(teamId : Team.TeamId) : PreCompiledHooks {
        var usedOnPlayers : TrieSet.Set<Player.PlayerId> = TrieSet.empty();
        let onDodge = func(request : Hook.HookRequest<Hook.SkillTestContext>) : Hook.HookResult<Hook.SkillTestContext> {
            let alreadyUsed = TrieSet.mem(usedOnPlayers, request.context.playerId, request.context.playerId, Nat32.equal);
            let updatedContext = if (not alreadyUsed) {
                usedOnPlayers := TrieSet.put(usedOnPlayers, request.context.playerId, request.context.playerId, Nat32.equal);
                request.state.log.add({
                    message = "Player " # Nat32.toText(request.context.playerId) # " is protected by a bubble!";
                    isImportant = false;
                });
                {
                    request.context with
                    result = {
                        request.context.result with
                        crit = true; // TODO what if already crit?
                    };
                };
            } else {
                request.context; //Skip
            };
            {
                updatedContext = updatedContext;
            };
        };
        {
            matchStart = null;
            matchEnd = null;
            roundStart = null;
            roundEnd = null;
            onDodge = ?onDodge;
            onPitch = null;
        };
    };

    // private func underdogHook(teamId : Team.TeamId) : PreCompiledHooks{
    //     func(request : Hook.HookRequest<()>) : Hook.HookResult<()> {

    //         {
    //             updatedContext = ();
    //         };
    //     };
    //     {
    //         matchStart = ?matchStartHook;
    //         roundStart = null;
    //         onDodge = null;
    //     };
    // };

    // private func piousHook(teamId : Team.TeamId) : PreCompiledHooks {
    //     func(request : Hook.HookRequest<()>) : Hook.HookResult<()> {

    //         {
    //             updatedContext = ();
    //         };
    //     };
    //     {
    //         matchStart = ?matchStartHook;
    //         roundStart = null;
    //         onDodge = null;
    //     };
    // };

    // private func confidentHook(teamId : Team.TeamId) : PreCompiledHooks {
    //     func(request : Hook.HookRequest<()>) : Hook.HookResult<()> {

    //         {
    //             updatedContext = ();
    //         };
    //     };
    //     {
    //         matchStart = ?matchStartHook;
    //         roundStart = null;
    //         onDodge = null;
    //     };
    // };

    // private func moraleFlywheelHook(teamId : Team.TeamId) : PreCompiledHooks {
    //     func(request : Hook.HookRequest<()>) : Hook.HookResult<()> {

    //         {

    //             updatedContext = ();
    //         };
    //     };
    //     {
    //         matchStart = ?matchStartHook;
    //         roundStart = null;
    //         onDodge = null;
    //     };
    // };
};
