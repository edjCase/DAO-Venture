<script lang="ts">
    import { Card, TabItem, Tabs } from "flowbite-svelte";
    import LeagueProposalList from "../dao/league/LeagueProposalList.svelte";
    import { teamStore } from "../../stores/TeamStore";
    import { userStore } from "../../stores/UserStore";
    import LoadingValue from "../common/LoadingValue.svelte";
    import { UserStats } from "../../ic-agent/declarations/users";

    let userStats: UserStats | undefined;

    userStore.subscribeStats((stats) => {
        userStats = stats;
    });

    $: teams = $teamStore;
    $: teamStatsMap = new Map(userStats?.teams.map((team) => [team.id, team]));
</script>

<div class="text-3xl text-center my-5">League</div>
<Tabs>
    <TabItem title="Summary" open>
        <div class="flex items-center">
            <span class="mr-2">Team Count:</span>
            <LoadingValue value={teams?.length} />
        </div>
        <div class="flex items-center">
            <span class="mr-2">Total User Count:</span>
            <LoadingValue value={userStats?.userCount} />
        </div>
        <div class="flex items-center">
            <span class="mr-2">Total Team Owners Count:</span>
            <LoadingValue value={userStats?.teamOwnerCount} />
        </div>
        <div class="flex items-center">
            <span class="mr-2">Total User Points:</span>
            <LoadingValue value={userStats?.totalPoints} />
        </div>
    </TabItem>
    <TabItem title="Teams">
        <div>
            {#if teams}
                {#each teams as team}
                    <Card class="my-5">
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
    <TabItem title="Proposals">
        <LeagueProposalList />
    </TabItem>
</Tabs>
