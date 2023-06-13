
export interface Game {
    id: number;
    team1: string;
    team2: string;
    stadium: string;
};

export interface CompletedGame extends Game {
    team1Score: number;
    team2Score: number;
};