<script lang="ts">
  import { MatchGroupDetails } from "../models/Match";
  import { SeasonStatus } from "../models/Season";
  import { scheduleStore } from "../stores/ScheduleStore";
  import MatchGroupSummaryCard from "./MatchGroupSummaryCard.svelte";
  import ScheduleSeason from "./ScheduleSeason.svelte";
  import { AccordionItem, Accordion } from "flowbite-svelte";

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
  {#if "notStarted" in seasonStatus}
    <div>
      <h1>Schedule Season</h1>
      <ScheduleSeason />
    </div>
  {:else if "completed" in seasonStatus}
    Season Complete
  {/if}
{/if}
{#if !!matchGroupDetails}
  <Accordion>
    {#each matchGroupDetails as matchGroup}
      <AccordionItem>
        <span slot="header">Week X</span>
        <MatchGroupSummaryCard {matchGroup} />
      </AccordionItem>
    {/each}
  </Accordion>
{/if}
