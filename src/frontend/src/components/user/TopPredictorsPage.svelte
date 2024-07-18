<script lang="ts">
    import { onMount } from "svelte";
    import { User } from "../../ic-agent/declarations/main";
    import UserAvatar from "./UserAvatar.svelte";
    import UserPseudonym from "./UserPseudonym.svelte";
    import { mainAgentFactory } from "../../ic-agent/Main";
    import LoadingButton from "../common/LoadingButton.svelte";

    let users: User[] = [];
    let offset = 0;
    let count = 10;
    let totalUsers = 0;

    let getTopUsers = async () => {
        let mainAgent = await mainAgentFactory();
        let result = await mainAgent.getUserLeaderboard({
            count: BigInt(count),
            offset: BigInt(offset),
        });
        if ("ok" in result) {
            users = result.ok.data;
            totalUsers = Number(result.ok.count);
        } else {
            console.error("Failed to get user leaderboard", result);
            users = [];
        }
    };

    $: currentPage = Math.floor(offset / count) + 1;
    $: totalPages = Math.ceil(totalUsers / count);

    async function nextPage() {
        if (offset + count < totalUsers) {
            offset += count;
            await getTopUsers();
        }
    }

    async function prevPage() {
        if (offset - count >= 0) {
            offset -= count;
            await getTopUsers();
        }
    }

    onMount(getTopUsers);
</script>

<div class="text-3xl text-center my-4">Top Predictors</div>
<div class="border-2 rounded border-gray-700 p-4">
    <div>
        {#each users as user, index}
            <div class="grid grid-cols-[3ch,20px,auto] gap-x-1 items-center">
                <div class="font-bold text-lg flex items-center justify-center">
                    {offset + index + 1}
                </div>
                <UserAvatar userId={user.id} size="md" border={false} />
                <UserPseudonym userId={user.id} maxWidth="100%" />
            </div>
        {/each}
    </div>
    <div class="flex justify-between items-center mt-4">
        <LoadingButton onClick={prevPage} disabled={currentPage === 1}>
            Previous
        </LoadingButton>
        <span>Page {currentPage} of {totalPages}</span>
        <LoadingButton onClick={nextPage} disabled={currentPage === totalPages}>
            Next
        </LoadingButton>
    </div>
</div>
