<script lang="ts">
  import { MatchGroupDetails } from "../../models/Match";
  import { SeasonStatus } from "../../models/Season";
  import { scheduleStore } from "../../stores/ScheduleStore";
  import MatchGroupSummaryCard from "./../match/MatchGroupSummaryCard.svelte";
  import { TabItem, Tabs } from "flowbite-svelte";

  let seasonStatus: SeasonStatus | undefined;

  scheduleStore.subscribeStatus((status) => {
    seasonStatus = status;
  });

  let matchGroupDetails: MatchGroupDetails[] | undefined;

  scheduleStore.subscribeMatchGroups((matchGroups: MatchGroupDetails[]) => {
    matchGroupDetails = matchGroups;
  });
</script>

{#if !!seasonStatus}
  <div class="text-center text-3xl font-bold my-4">
    {#if "notStarted" in seasonStatus}
      Season Not Started
    {:else if "completed" in seasonStatus}
      Season Complete
    {:else}
      Season InProgress
    {/if}
  </div>
{/if}
{#if !!matchGroupDetails}
  <Tabs
    style="full"
    defaultClass="flex rounded-lg divide-x shadow divide-gray-700"
  >
    {#each matchGroupDetails as matchGroup, index}
      <TabItem
        class="w-full"
        title="Week {index + 1}"
        open={matchGroup.state == "InProgress" ||
          matchGroup.state == "Scheduled"}
      >
        <div class="tab-content">
          <MatchGroupSummaryCard {matchGroup} />
        </div>
      </TabItem>
    {/each}
  </Tabs>
{/if}

<style>
  .tab-content {
    display: flex;
    flex-direction: row;
    align-items: center;
    justify-content: center;
  }
</style>
