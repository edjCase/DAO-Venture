export interface Proposal {
    id: number;
    title: string;
    status: "pending" | "adopted" | "rejected";
    description: string;
};