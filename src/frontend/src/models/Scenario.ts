import type { Principal } from '@dfinity/principal';
import { IDL } from "@dfinity/candid";
import { FieldPosition, FieldPositionIdl, Injury, InjuryIdl } from './Player';
import { Skill, SkillIdl } from './Skill';

export type Nat = bigint;
export const NatIdl = IDL.Nat;
export type Nat8 = number;
export type Nat32 = number;
export type Int = number;
export type Text = string;


export type TargetInstance =
    | { league: null }
    | { teams: Principal[] }
    | { players: Nat32[] };
export const TargetInstanceIdl = IDL.Variant({
    league: IDL.Null,
    teams: IDL.Vec(IDL.Principal),
    players: IDL.Vec(IDL.Nat32),
});

export type TargetTeam =
    | { choosingTeam: null };
export const TargetTeamIdl = IDL.Variant({
    choosingTeam: IDL.Null,
});

export type TargetPlayer = {
    position: FieldPosition;
};
export const TargetPlayerIdl = IDL.Record({
    position: FieldPositionIdl,
});

export type Target =
    | { league: null }
    | { teams: TargetTeam[] }
    | { players: TargetPlayer[] };
export const TargetIdl = IDL.Variant({
    league: IDL.Null,
    teams: IDL.Vec(TargetTeamIdl),
    players: IDL.Vec(TargetPlayerIdl),
});

export type Duration =
    | { indefinite: null }
    | { matches: Nat };
export const DurationIdl = IDL.Variant({
    indefinite: IDL.Null,
    matches: NatIdl,
});



export type Effect =
    | {
        skill: {
            target: Target;
            skill: Skill;
            duration: Duration;
            delta: Int;
        };
    }
    | {
        injury: {
            target: Target;
            injury: Injury;
        };
    }
    | {
        entropy: {
            team: TargetTeam;
            delta: Int;
        };
    }
    | {
        energy: {
            team: TargetTeam;
            value: { flat: Int };
        };
    }
    | { oneOf: [Nat, Effect][] }
    | { allOf: Effect[] }
    | { noEffect: null };

export const EffectIdl = IDL.Rec();
EffectIdl.fill(IDL.Variant({
    skill: IDL.Record({
        target: TargetIdl,
        skill: SkillIdl,
        duration: DurationIdl,
        delta: IDL.Int,
    }),
    injury: IDL.Record({
        target: TargetIdl,
        injury: InjuryIdl,
    }),
    entropy: IDL.Record({
        team: TargetTeamIdl,
        delta: IDL.Int,
    }),
    energy: IDL.Record({
        team: TargetTeamIdl,
        value: IDL.Variant({ flat: IDL.Int }),
    }),
    oneOf: IDL.Vec(IDL.Tuple(NatIdl, EffectIdl)),
    allOf: IDL.Vec(EffectIdl),
    noEffect: IDL.Null,
}));

export type ScenarioEffectOption = {
    value: { fixed: Int } | { weightedChance: [Nat, Int][] };
};
export const ScenarioEffectOptionIdl = IDL.Record({
    value: IDL.Variant({
        fixed: IDL.Int,
        weightedChance: IDL.Vec(IDL.Tuple(NatIdl, IDL.Int)),
    }),
});

export type ScenarioEffect =
    | {
        threshold: {
            threshold: Nat;
            over: Effect;
            under: Effect;
            options: ScenarioEffectOption[];
        };
    }
    | {
        leagueChoice: {
            options: { effect: Effect }[];
        };
    }
    | {
        pickASide: {
            options: { sideId: Text }[];
        };
    }
    | {
        lottery: {
            prize: Effect;
            options: { tickets: Nat }[];
        };
    }
    | {
        proportionalBid: {
            prize: {
                skill: {
                    skill: Skill;
                    target: { position: FieldPosition };
                    duration: Duration;
                    total: Nat;
                };
            };
            options: { bidValue: Nat }[];
        };
    }
    | { simple: null };
export const ScenarioEffectIdl = IDL.Variant({
    threshold: IDL.Record({
        threshold: NatIdl,
        over: EffectIdl,
        under: EffectIdl,
        options: IDL.Vec(ScenarioEffectOptionIdl),
    }),
    leagueChoice: IDL.Record({
        options: IDL.Vec(IDL.Record({ effect: EffectIdl })),
    }),
    pickASide: IDL.Record({
        options: IDL.Vec(IDL.Record({ sideId: IDL.Text })),
    }),
    lottery: IDL.Record({
        prize: EffectIdl,
        options: IDL.Vec(IDL.Record({ tickets: NatIdl })),
    }),
    proportionalBid: IDL.Record({
        prize: IDL.Record({
            skill: IDL.Record({
                skill: SkillIdl,
                target: IDL.Variant({ position: FieldPositionIdl }),
                duration: DurationIdl,
                total: NatIdl,
            }),
        }),
        options: IDL.Vec(IDL.Record({ bidValue: NatIdl })),
    }),
    simple: IDL.Null,
});

export type PlayerEffectOutcome =
    | {
        skill: {
            target: TargetInstance;
            skill: Skill;
            duration: Duration;
            delta: Int;
        };
    }
    | {
        injury: {
            target: TargetInstance;
            injury: Injury;
        };
    };
export const PlayerEffectOutcomeIdl = IDL.Variant({
    skill: IDL.Record({
        target: TargetInstanceIdl,
        skill: SkillIdl,
        duration: DurationIdl,
        delta: IDL.Int,
    }),
    injury: IDL.Record({
        target: TargetInstanceIdl,
        injury: InjuryIdl,
    }),
});

export type TeamEffectOutcome =
    | {
        entropy: {
            teamId: Principal;
            delta: Int;
        };
    }
    | {
        energy: {
            teamId: Principal;
            delta: Int;
        };
    };
export const TeamEffectOutcomeIdl = IDL.Variant({
    entropy: IDL.Record({
        teamId: IDL.Principal,
        delta: IDL.Int,
    }),
    energy: IDL.Record({
        teamId: IDL.Principal,
        delta: IDL.Int,
    }),
});

export type EffectOutcome = PlayerEffectOutcome | TeamEffectOutcome;
export const EffectOutcomeIdl = IDL.Variant({
    skill: IDL.Record({
        target: TargetInstanceIdl,
        skill: SkillIdl,
        duration: DurationIdl,
        delta: IDL.Int,
    }),
    injury: IDL.Record({
        target: TargetInstanceIdl,
        injury: InjuryIdl,
    }),
    entropy: IDL.Record({
        teamId: IDL.Principal,
        delta: IDL.Int,
    }),
    energy: IDL.Record({
        teamId: IDL.Principal,
        delta: IDL.Int,
    }),
});


export type ScenarioOption = {
    title: Text;
    description: Text;
    effect: Effect;
};
export const ScenarioOptionIdl = IDL.Record({
    title: IDL.Text,
    description: IDL.Text,
    effect: EffectIdl,
});

export type Scenario = {
    id: Text;
    title: Text;
    description: Text;
    options: ScenarioOption[];
    effect: ScenarioEffect;
};
export const ScenarioIdl = IDL.Record({
    id: IDL.Text,
    title: IDL.Text,
    description: IDL.Text,
    options: IDL.Vec(ScenarioOptionIdl),
    effect: ScenarioEffectIdl,
});

export type TeamChoice = {
    teamId: Principal;
    choiceIndex: Nat8;
};
export const TeamChoiceIdl = IDL.Record({
    teamId: IDL.Principal,
    choiceIndex: IDL.Nat8,
});

export type ResolvedScenario = Scenario & {
    teamChoices: TeamChoice[];
    effectOutcomes: EffectOutcome[];
};
export const ResolvedScenarioIdl = IDL.Record({
    id: IDL.Text,
    title: IDL.Text,
    description: IDL.Text,
    options: IDL.Vec(ScenarioOptionIdl),
    effect: ScenarioEffectIdl,
    teamChoices: IDL.Vec(TeamChoiceIdl),
    effectOutcomes: IDL.Vec(EffectOutcomeIdl),
});
