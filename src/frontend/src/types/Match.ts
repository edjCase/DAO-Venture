export interface Match {
    id: number;
    team1: TeamMatchSnapshot;
    team2: TeamMatchSnapshot;
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


export interface TeamMatchSnapshot {
    id: number;
    name: string;
    logo: string;
    players: PlayerInfo[];
    votes: number;
    matchStats?: TeamMatchStats;
};

export interface TeamMatchStats {
    score: number;
};

export interface PlayerInfo {
    id: number;
    name: string;
    position: string;
    matchStats?: PlayerMatchStats;
};

export interface PlayerMatchStats {
    runs: number;
    hits: number;
    errors: number;
};