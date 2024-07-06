<script lang="ts">
    import { onMount } from "svelte";
    import UserAvatar from "../user/UserAvatar.svelte";
    import UserPseudonym from "../user/UserPseudonym.svelte";
    import { UserVotingInfo } from "../../ic-agent/declarations/main";
    import { mainAgentFactory } from "../../ic-agent/Main";

    export let teamId: bigint;

    let members: UserVotingInfo[] = [];

    let getUsers = async () => {
        let mainAgent = await mainAgentFactory();
        let result = await mainAgent.getTeamOwners({ team: teamId });
        if ("ok" in result) {
            members = result.ok;
        } else {
            console.error("Failed to get team owners: ", result);
        }
    };

    onMount(getUsers);
</script>

{#each members as member}
    <div class="border p-5">
        <UserAvatar userId={member.id} />
        <UserPseudonym userId={member.id} />
        <div>{member.id}</div>
    </div>
{/each}
