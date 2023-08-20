import { writable } from "svelte/store";
import { agent as leagueAgent } from "../ic-agent/league"



const { subscribe, set, update } = writable([]);

export const stadiumStore = {
  subscribe,
  get : () => {
    leagueAgent.getStadiums().then((stadiums) => {
        set(stadiums);
    });
  }
};
