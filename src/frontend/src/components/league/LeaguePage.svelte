<script lang="ts">
    import { Card, TabItem, Tabs } from "flowbite-svelte";
    import LeagueProposalList from "../dao/league/LeagueProposalList.svelte";
    import { teamStore } from "../../stores/TeamStore";
    import { userStore } from "../../stores/UserStore";
    import LoadingValue from "../common/LoadingValue.svelte";
    import { UserStats } from "../../ic-agent/declarations/main";

    let userStats: UserStats | undefined;

    userStore.subscribeStats((stats) => {
        userStats = stats;
    });

    $: teams = $teamStore;
    $: teamStatsMap = new Map(userStats?.teams.map((team) => [team.id, team]));
</script>

<div class="text-3xl text-center my-5">League</div>
<div class="text-center">
    <div class="flex items-center justify-center">
        <span class="mr-2">Teams:</span>
        <LoadingValue value={teams?.length} />
    </div>
    <div class="flex items-center justify-center">
        <span class="mr-2">Users:</span>
        <LoadingValue value={userStats?.userCount} />
    </div>
    <div class="flex items-center justify-center">
        <span class="mr-2">Team Owners:</span>
        <LoadingValue value={userStats?.teamOwnerCount} />
    </div>
    <div class="flex items-center justify-center">
        <span class="mr-2">Total User Points:</span>
        <LoadingValue value={userStats?.totalPoints} />
    </div>
</div>
<Tabs>
    <TabItem title="Proposals" open>
        <LeagueProposalList />
    </TabItem>
    <TabItem title="Teams">
        <div class="flex flex-col items-center">
            {#if teams}
                {#each teams as team}
                    <Card class="my-2 w-full">
                        <div class="text-3xl text-center">
                            <LoadingValue value={team.name} />
                        </div>
                        <div class="flex items-center">
                            <span class="mr-2">Team Id:</span>
                            <LoadingValue value={team.id} />
                        </div>
                        <div class="flex items-center">
                            <span class="mr-2">User Count:</span>
                            <LoadingValue
                                value={teamStatsMap.get(team.id)?.userCount}
                            />
                        </div>
                        <div class="flex items-center">
                            <span class="mr-2">Team Owner Count:</span>
                            <LoadingValue
                                value={teamStatsMap.get(team.id)?.ownerCount}
                            />
                        </div>
                        <div class="flex items-center">
                            <span class="mr-2">Team Total Points:</span>
                            <LoadingValue
                                value={teamStatsMap.get(team.id)?.totalPoints}
                            />
                        </div>
                    </Card>
                {/each}
            {/if}
        </div>
    </TabItem>
</Tabs>
