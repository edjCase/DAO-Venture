<script lang="ts">
    import { Card, TabItem, Tabs } from "flowbite-svelte";
    import WorldProposalList from "../dao/world/WorldProposalList.svelte";
    import { townStore } from "../../stores/TownStore";
    import { userStore } from "../../stores/UserStore";
    import LoadingValue from "../common/LoadingValue.svelte";
    import { UserStats } from "../../ic-agent/declarations/main";
    import WorldProposalForm from "../dao/world/WorldProposalForm.svelte";

    let userStats: UserStats | undefined;

    userStore.subscribeStats((stats) => {
        userStats = stats;
    });

    $: towns = $townStore;
    $: townStatsMap = new Map(userStats?.towns.map((town) => [town.id, town]));
</script>

<div class="text-3xl text-center my-5">World</div>
<div class="text-center">
    <div class="flex items-center justify-center">
        <span class="mr-2">Towns:</span>
        <LoadingValue value={towns?.length} />
    </div>
    <div class="flex items-center justify-center">
        <span class="mr-2">Users:</span>
        <LoadingValue value={userStats?.userCount} />
    </div>
    <div class="flex items-center justify-center">
        <span class="mr-2">Town Owners:</span>
        <LoadingValue value={userStats?.townOwnerCount} />
    </div>
    <div class="flex items-center justify-center">
        <span class="mr-2">Total User Points:</span>
        <LoadingValue value={userStats?.totalPoints} />
    </div>
</div>
<Tabs>
    <TabItem title="Proposals" open>
        <WorldProposalList />
        <WorldProposalForm />
    </TabItem>
    <TabItem title="Towns">
        <div class="flex flex-col items-center">
            {#if towns}
                {#each towns as town}
                    <Card class="my-2 w-full">
                        <div class="text-3xl text-center">
                            <LoadingValue value={town.name} />
                        </div>
                        <div class="flex items-center">
                            <span class="mr-2">Town Id:</span>
                            <LoadingValue value={town.id} />
                        </div>
                        <div class="flex items-center">
                            <span class="mr-2">User Count:</span>
                            <LoadingValue
                                value={townStatsMap.get(town.id)?.userCount}
                            />
                        </div>
                        <div class="flex items-center">
                            <span class="mr-2">Town Owner Count:</span>
                            <LoadingValue
                                value={townStatsMap.get(town.id)?.ownerCount}
                            />
                        </div>
                        <div class="flex items-center">
                            <span class="mr-2">Town Total Points:</span>
                            <LoadingValue
                                value={townStatsMap.get(town.id)?.totalPoints}
                            />
                        </div>
                    </Card>
                {/each}
            {/if}
        </div>
    </TabItem>
</Tabs>
