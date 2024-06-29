import { resolve } from "path";
import fs from "fs";

export function initCanisterIds(production: boolean): { canisterIds: Record<string, Record<string, string>>, network: string } {
    const network = process.env.DFX_NETWORK || (production ? "ic" : "local")

    let localCanisters = {}
    let prodCanisters = {}

    try {
        localCanisters = JSON.parse(fs.readFileSync(resolve("..", "..", ".dfx", "local", "canister_ids.json")).toString())
    } catch (error) {
        console.log("No local canister_ids.json found. Continuing production")
    }

    try {
        prodCanisters = JSON.parse(fs.readFileSync(resolve("..", "..", "canister_ids.json")).toString())
    } catch (error) {
        console.log("No production canister_ids.json found. Continuing with local")
    }

    const canisterIds = network === "local" ? { ...(localCanisters || {}) } : prodCanisters

    return { canisterIds, network }
}