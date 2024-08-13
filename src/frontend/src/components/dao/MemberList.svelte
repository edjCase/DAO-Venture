<script lang="ts">
    import UserAvatar from "../user/UserAvatar.svelte";
    import UserPseudonym from "../user/UserPseudonym.svelte";
    import { mainAgentFactory } from "../../ic-agent/Main";
    import UserIdCopyButton from "../user/UserIdCopyButton.svelte";
    import { User } from "../../ic-agent/declarations/main";

    let members: User[] | undefined;

    let refreshUsers = async () => {
        let mainAgent = await mainAgentFactory();
        let result = await mainAgent.getUsers({ all: null });
        if ("ok" in result) {
            members = result.ok;
        } else {
            console.error("Failed to get town owners: ", result);
        }
    };
    refreshUsers();
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
