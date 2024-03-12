import StadiumTypes "Types";
import Hook "../models/Hook";
import PseudoRandomX "mo:random/PseudoRandomX";
import Iter "mo:base/Iter";

module {
    type Prng = PseudoRandomX.PseudoRandomGenerator;

    public type PreCompiledHooks = {
        matchStart : ?Hook.Hook<()>;
        matchEnd : ?Hook.Hook<()>;
        roundStart : ?Hook.Hook<()>;
        roundEnd : ?Hook.Hook<()>;
        onDodge : ?Hook.Hook<Hook.SkillTestContext>;
        onPitch : ?Hook.Hook<Hook.SkillTestContext>;
        onSwing : ?Hook.Hook<Hook.SkillTestContext>;
        onHit : ?Hook.Hook<Hook.SkillTestContext>;
        onCatch : ?Hook.Hook<Hook.SkillTestContext>;
    };

    public func compile(_ : StadiumTypes.InProgressMatch) : Hook.CompiledHooks {
        let allHooks = [
            // fromAura(state.aura)
        ];

        var matchStart : ?Hook.Hook<()> = null;
        var matchEnd : ?Hook.Hook<()> = null;
        var roundStart : ?Hook.Hook<()> = null;
        var roundEnd : ?Hook.Hook<()> = null;
        var onDodge : ?Hook.Hook<Hook.SkillTestContext> = null;
        var onPitch : ?Hook.Hook<Hook.SkillTestContext> = null;
        var onSwing : ?Hook.Hook<Hook.SkillTestContext> = null;
        var onHit : ?Hook.Hook<Hook.SkillTestContext> = null;
        var onCatch : ?Hook.Hook<Hook.SkillTestContext> = null;
        for (hook in Iter.fromArray(allHooks)) {
            matchStart := mergeHook(matchStart, hook.matchStart);
            matchEnd := mergeHook(matchEnd, hook.matchEnd);
            roundStart := mergeHook(roundStart, hook.roundStart);
            roundEnd := mergeHook(roundEnd, hook.roundEnd);
            onDodge := mergeHook(onDodge, hook.onDodge);
            onPitch := mergeHook(onPitch, hook.onPitch);
            onSwing := mergeHook(onSwing, hook.onSwing);
            onHit := mergeHook(onHit, hook.onHit);
            onCatch := mergeHook(onCatch, hook.onCatch);
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
            onSwing = hookOrEmpty(onSwing);
            onHit = hookOrEmpty(onHit);
            onCatch = hookOrEmpty(onCatch);
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
                            request with
                            context = result1.updatedContext;
                        };
                        let result2 = h2(request2);
                        {
                            updatedContext = result2.updatedContext;
                        };
                    }
                );
            };
        };
    };

    // private func shuffleAndBoostHook(teamId : Team.TeamId) : PreCompiledHooks {
    //     let matchStartHook = func(request : Hook.HookRequest<()>) : Hook.HookResult<()> {
    //         // Shuffle all the players' positions but boost their stats

    //         let team = switch (teamId) {
    //             case (#team1) request.state.team1;
    //             case (#team2) request.state.team2;
    //         };

    //         // Shuffle positions
    //         let newPositions = Buffer.fromArray<Player.PlayerId>([
    //             team.positions.pitcher,
    //             team.positions.firstBase,
    //             team.positions.secondBase,
    //             team.positions.thirdBase,
    //             team.positions.shortStop,
    //             team.positions.leftField,
    //             team.positions.centerField,
    //             team.positions.rightField,
    //         ]);
    //         request.prng.shuffleBuffer(newPositions);

    //         team.positions.pitcher := newPositions.get(0);
    //         team.positions.firstBase := newPositions.get(1);
    //         team.positions.secondBase := newPositions.get(2);
    //         team.positions.thirdBase := newPositions.get(3);
    //         team.positions.shortStop := newPositions.get(4);
    //         team.positions.leftField := newPositions.get(5);
    //         team.positions.centerField := newPositions.get(6);
    //         team.positions.rightField := newPositions.get(7);

    //         // Boost skills
    //         let randomSkill = Skill.getRandom(request.prng);
    //         for ((playerId, playerState) in request.state.getTeamPlayers(teamId)) {
    //             MutableState.modifyPlayerSkill(playerState.skills, randomSkill, 1);
    //         };
    //         {
    //             updatedContext = ();
    //         };
    //     };
    //     {
    //         matchStart = ?matchStartHook;
    //         matchEnd = null;
    //         roundStart = null;
    //         roundEnd = null;
    //         onDodge = null;
    //         onPitch = null;
    //         onSwing = null;
    //         onHit = null;
    //         onCatch = null;
    //     };
    // };

    // private func offensiveHook(teamId : Team.TeamId) : PreCompiledHooks {
    //     let matchStartHook = func(request : Hook.HookRequest<()>) : Hook.HookResult<()> {
    //         // Increase batting power and lower catching
    //         for ((playerId, playerState) in request.state.getTeamPlayers(teamId)) {
    //             MutableState.modifyPlayerSkill(playerState.skills, #battingPower, 1);
    //             MutableState.modifyPlayerSkill(playerState.skills, #catching, -1);
    //         };
    //         {
    //             updatedContext = ();
    //         };
    //     };
    //     {
    //         matchStart = ?matchStartHook;
    //         matchEnd = null;
    //         roundStart = null;
    //         roundEnd = null;
    //         onDodge = null;
    //         onPitch = null;
    //         onSwing = null;
    //         onHit = null;
    //         onCatch = null;
    //     };
    // };

    // private func defensiveHook(teamId : Team.TeamId) : PreCompiledHooks {
    //     let matchStartHook = func(request : Hook.HookRequest<()>) : Hook.HookResult<()> {
    //         // Increase catching and lower batting power
    //         for ((playerId, playerState) in request.state.getTeamPlayers(teamId)) {
    //             MutableState.modifyPlayerSkill(playerState.skills, #catching, 1);
    //             MutableState.modifyPlayerSkill(playerState.skills, #battingPower, -1);
    //         };
    //         {
    //             updatedContext = ();
    //         };
    //     };
    //     {
    //         matchStart = ?matchStartHook;
    //         matchEnd = null;
    //         roundStart = null;
    //         roundEnd = null;
    //         onDodge = null;
    //         onPitch = null;
    //         onSwing = null;
    //         onHit = null;
    //         onCatch = null;
    //     };
    // };

    // private func hittersDebtHook(teamId : Team.TeamId) : PreCompiledHooks {
    //     let matchStartHook = func(request : Hook.HookRequest<()>) : Hook.HookResult<()> {
    //         switch (teamId) {
    //             case (#team1) {
    //                 request.state.team1.score -= 1;
    //             };
    //             case (#team2) {
    //                 request.state.team2.score -= 1;
    //             };
    //         };
    //         {
    //             updatedContext = ();
    //         };
    //     };
    //     {
    //         matchStart = ?matchStartHook;
    //         matchEnd = null;
    //         roundStart = null;
    //         roundEnd = null;
    //         onDodge = null;
    //         onPitch = null;
    //         onSwing = null;
    //         onHit = null;
    //         onCatch = null;
    //     };
    // };

    // private func ragePitchHook(teamId : Team.TeamId) : PreCompiledHooks {
    //     let matchStartHook = func(request : Hook.HookRequest<()>) : Hook.HookResult<()> {
    //         // Increase throwing power and lower throwing accuracy for pitchers
    //         let teamState = request.state.getTeamState(teamId);
    //         let playerState = request.state.getPlayerState(teamState.positions.pitcher);
    //         MutableState.modifyPlayerSkill(playerState.skills, #throwingPower, 1);
    //         MutableState.modifyPlayerSkill(playerState.skills, #throwingAccuracy, -1);
    //         {
    //             updatedContext = ();
    //         };
    //     };
    //     {
    //         matchStart = ?matchStartHook;
    //         matchEnd = null;
    //         roundStart = null;
    //         roundEnd = null;
    //         onDodge = null;
    //         onPitch = null;
    //         onSwing = null;
    //         onHit = null;
    //         onCatch = null;
    //     };
    // };

    // private func bubbleHook(teamId : Team.TeamId) : PreCompiledHooks {
    //     var usedOnPlayers : TrieSet.Set<Player.PlayerId> = TrieSet.empty();
    //     let onDodge = func(request : Hook.HookRequest<Hook.SkillTestContext>) : Hook.HookResult<Hook.SkillTestContext> {
    //         let alreadyUsed = TrieSet.mem(usedOnPlayers, request.context.playerId, request.context.playerId, Nat32.equal);
    //         let updatedContext = if (not alreadyUsed) {
    //             usedOnPlayers := TrieSet.put(usedOnPlayers, request.context.playerId, request.context.playerId, Nat32.equal);

    //             {
    //                 request.context with
    //                 result = {
    //                     request.context.result with
    //                     crit = true; // TODO what if already crit?
    //                 };
    //             };
    //         } else {
    //             request.context; //Skip
    //         };
    //         {
    //             updatedContext = updatedContext;
    //         };
    //     };
    //     {
    //         matchStart = null;
    //         matchEnd = null;
    //         roundStart = null;
    //         roundEnd = null;
    //         onDodge = ?onDodge;
    //         onPitch = null;
    //         onSwing = null;
    //         onHit = null;
    //         onCatch = null;
    //     };
    // };

    // private func underdogHook(teamId : Team.TeamId) : PreCompiledHooks {
    //     // Better stats when team is behind, worse when ahead
    //     let roundStartHook = func(request : Hook.HookRequest<()>) : Hook.HookResult<()> {
    //         // TODO
    //         {
    //             updatedContext = ();
    //         };
    //     };
    //     {
    //         matchStart = null;
    //         matchEnd = null;
    //         roundStart = ?roundStartHook;
    //         roundEnd = null;
    //         onDodge = null;
    //         onPitch = null;
    //         onSwing = null;
    //         onHit = null;
    //         onCatch = null;
    //     };
    // };

    // private func piousHook(teamId : Team.TeamId) : PreCompiledHooks {
    //     let roundStartHook = func(request : Hook.HookRequest<()>) : Hook.HookResult<()> {
    //         // TODO
    //         {
    //             updatedContext = ();
    //         };
    //     };
    //     {
    //         matchStart = null;
    //         matchEnd = null;
    //         roundStart = ?roundStartHook;
    //         roundEnd = null;
    //         onDodge = null;
    //         onPitch = null;
    //         onSwing = null;
    //         onHit = null;
    //         onCatch = null;
    //     };
    // };

    // private func confidentHook(teamId : Team.TeamId) : PreCompiledHooks {
    //     let roundStartHook = func(request : Hook.HookRequest<()>) : Hook.HookResult<()> {
    //         // TODO
    //         {
    //             updatedContext = ();
    //         };
    //     };
    //     {
    //         matchStart = null;
    //         matchEnd = null;
    //         roundStart = ?roundStartHook;
    //         roundEnd = null;
    //         onDodge = null;
    //         onPitch = null;
    //         onSwing = null;
    //         onHit = null;
    //         onCatch = null;
    //     };
    // };

    // private func moraleFlywheelHook(teamId : Team.TeamId) : PreCompiledHooks {
    //     let roundStartHook = func(request : Hook.HookRequest<()>) : Hook.HookResult<()> {
    //         // TODO
    //         {
    //             updatedContext = ();
    //         };
    //     };
    //     {
    //         matchStart = null;
    //         matchEnd = null;
    //         roundStart = ?roundStartHook;
    //         roundEnd = null;
    //         onDodge = null;
    //         onPitch = null;
    //         onSwing = null;
    //         onHit = null;
    //         onCatch = null;
    //     };
    // };

    // private func badManagementHook(teamId : Team.TeamId) : PreCompiledHooks {
    //     let matchStartHook = func(request : Hook.HookRequest<()>) : Hook.HookResult<()> {
    //         // TODO
    //         {
    //             updatedContext = ();
    //         };
    //     };
    //     {
    //         matchStart = ?matchStartHook;
    //         matchEnd = null;
    //         roundStart = null;
    //         roundEnd = null;
    //         onDodge = null;
    //         onPitch = null;
    //         onSwing = null;
    //         onHit = null;
    //         onCatch = null;
    //     };
    // };
};
