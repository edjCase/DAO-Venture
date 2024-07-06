<script lang="ts">
    import { onMount } from "svelte";
    import { User } from "../../ic-agent/declarations/main";
    import UserAvatar from "./UserAvatar.svelte";

    import UserPseudonym from "./UserPseudonym.svelte";
    import SectionWithOverview from "../common/SectionWithOverview.svelte";
    import { mainAgentFactory } from "../../ic-agent/Main";

    let users: User[] = [];

    let getTopUsers = async () => {
        let mainAgent = await mainAgentFactory();
        let result = await mainAgent.getUserLeaderboard({
            count: BigInt(10),
            offset: BigInt(0),
        }); // TODO paging
        if ("ok" in result) {
            users = result.ok.data;
        } else {
            console.error("Failed to get user leaderboard", result);
            users = [];
        }
    };

    onMount(getTopUsers);
</script>

{#if users.length > 0}
    <SectionWithOverview title="User Leaderboard">
        <div class="border-2 rounded border-gray-700 p-4">
            {#each users as user, index}
                <div class="flex items-center justify-center">
                    <div class="mr-2">
                        #{index + 1}
                    </div>
                    <UserAvatar userId={user.id} size="lg" border={false} />
                    <div class="ml-2">
                        <UserPseudonym userId={user.id} />
                    </div>
                    <div class="ml-4 bold text-xl">{user.points}</div>
                </div>
            {/each}
        </div>
    </SectionWithOverview>
{/if}
