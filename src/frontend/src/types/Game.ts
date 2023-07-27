export interface Game {
    id: number;
    team1: TeamGameSnapshot;
    team2: TeamGameSnapshot;
    stadium: {
        id: number;
        name: string;
    };
    start: Date;
    end?: Date;
    winningTeamId?: number;
    events: Event[];
};

export interface Team {
    id: number;
    name: string;
    logo: string;
};


export interface Event {
    inning: number;
    topHalf: boolean;
    info: ScoreEventInfo | InjuryEventInfo;
};

export interface ScoreEventInfo {
    type: "score";
    battingPlayerId: number;
    scoringPlayerIds: number[];
};

export interface InjuryEventInfo {
    type: "injury";
    playerId: number;
    injury: string;
};


export interface TeamGameSnapshot {
    id: number;
    name: string;
    logo: string;
    players: PlayerInfo[];
    votes: number;
    gameStats?: TeamGameStats;
};

export interface TeamGameStats {
    score: number;
};

export interface PlayerInfo {
    id: number;
    name: string;
    position: string;
    gameStats?: PlayerGameStats;
};

export interface PlayerGameStats {
    runs: number;
    hits: number;
    errors: number;
};