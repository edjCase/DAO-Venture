import { Writable, writable } from "svelte/store";
import { Member } from "../ic-agent/declarations/team";
import { teamAgentFactory } from "../ic-agent/Team";
import { Principal } from "@dfinity/principal";



export const memberStore = (() => {
    let teamStores = new Map<string, Writable<Member[]>>();

    const getOrCreateTeamStore = (teamId: string | Principal) => {
        if (teamId instanceof Principal) {
            teamId = teamId.toText();
        }
        let store = teamStores.get(teamId);
        if (!store) {
            store = writable<Member[]>([]);
            teamStores.set(teamId, store);
            refetchTeamMembers(teamId);
        };
        return store;
    };

    const refetchTeamMember = async (teamId: string | Principal, memberId: Principal) => {
        let store = getOrCreateTeamStore(teamId);
        let memberResult = await teamAgentFactory(teamId).getMember(memberId);
        if (memberResult.length === 0) {
            throw new Error("Member not found: " + memberId + " for team: " + teamId);
        }
        let member = memberResult[0];
        store.update((current) => {
            let index = current.findIndex(p => p.id.compareTo(memberId) == "eq");
            if (index >= 0) {
                current[index] = member;
            } else {
                current.push(member);
            }
            return current;
        });
    }

    const refetchTeamMembers = async (teamId: string | Principal) => {
        let store = getOrCreateTeamStore(teamId);
        let members = await teamAgentFactory(teamId).getMembers();
        store.set(members);
    };

    const subscribeToTeam = (teamId: string | Principal, callback: (value: Member[]) => void) => {
        let store = getOrCreateTeamStore(teamId);
        return store.subscribe(callback);
    }

    return {
        subscribeToTeam,
        refetchTeamMembers,
        refetchTeamMember
    };
})();


