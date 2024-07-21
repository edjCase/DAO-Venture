<script lang="ts">
    import { onMount } from "svelte";
    import { User } from "../../ic-agent/declarations/main";
    import UserAvatar from "./UserAvatar.svelte";

    import UserPseudonym from "./UserPseudonym.svelte";
    import { mainAgentFactory } from "../../ic-agent/Main";
    import { Link } from "svelte-routing";
    import { ArrowUpRightFromSquareOutline } from "flowbite-svelte-icons";

    let users: User[] = [];

    let getTopUsers = async () => {
        let mainAgent = await mainAgentFactory();
        let result = await mainAgent.getTopUsers({
            count: BigInt(3),
            offset: BigInt(0),
        }); // TODO paging
        if ("ok" in result) {
            users = result.ok.data;
        } else {
            console.error("Failed to get top users", result);
            users = [];
        }
    };

    onMount(getTopUsers);
</script>

<div class="flex-grow">
    <div class="text-3xl text-center">Top Users</div>
    <div class="border-2 rounded border-gray-700 p-4 h-[154px]">
        <div>
            {#each users as user}
                <div
                    class="grid grid-cols-[3ch,20px,auto] gap-x-1 items-center"
                >
                    <div
                        class="font-bold text-lg flex items-center justify-center"
                    >
                        {user.level}
                    </div>
                    <UserAvatar userId={user.id} size="md" border={false} />
                    <UserPseudonym userId={user.id} maxWidth="100%" />
                </div>
            {/each}
        </div>
        <div class="flex justify-center">
            <Link to="/top-predictors">
                <div
                    class="text-center border rounded border-2 border-gray-700 p-2 flex items-center justify-between gap-2"
                >
                    See All
                    <ArrowUpRightFromSquareOutline size="xs" />
                </div>
            </Link>
        </div>
    </div>
</div>
