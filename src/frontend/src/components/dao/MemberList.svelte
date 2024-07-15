<script lang="ts">
    import UserAvatar from "../user/UserAvatar.svelte";
    import UserPseudonym from "../user/UserPseudonym.svelte";
    import { UserVotingInfo } from "../../ic-agent/declarations/main";
    import { mainAgentFactory } from "../../ic-agent/Main";
    import UserIdCopyButton from "../user/UserIdCopyButton.svelte";

    export let teamId: bigint;

    let members: UserVotingInfo[] | undefined;

    let refreshUsers = async (teamId: bigint) => {
        let mainAgent = await mainAgentFactory();
        let result = await mainAgent.getTeamOwners({ team: teamId });
        if ("ok" in result) {
            members = result.ok;
        } else {
            console.error("Failed to get team owners: ", result);
        }
    };
    $: refreshUsers(teamId);
</script>

{#if members}
    {#each members as member}
        <div class="border p-5 flex gap-2">
            <UserAvatar userId={member.id} />
            <UserPseudonym userId={member.id} />
            <UserIdCopyButton userId={member.id} />
        </div>
    {/each}
{:else}
    Loading...
{/if}
