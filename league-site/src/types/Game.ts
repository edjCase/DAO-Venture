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
    scorings: InningScoreEntry[];
};

export interface Team {
    id: number;
    name: string;
    logo: string;
};


export interface InningScoreEntry {
    inning: number;
    topHalf: boolean;
    battingPlayerId: number;
    scoringPlayerIds: number[];
}; 


export interface TeamGameSnapshot {
    id : number;
    name : string;
    logo : string;
    players: PlayerInfo[];
    votes : number;
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