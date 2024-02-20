<script lang="ts">
  import {
    ArrowKeyLeft,
    ArrowKeyRight,
    ArrowKeyDown,
    Button,
    Dropdown,
    DropdownItem,
    Helper,
  } from "flowbite-svelte";
  import { MatchGroupDetails } from "../../models/Match";
  import { nanosecondsToDate } from "../../utils/DateUtils";
  import MatchGroup from "../match/MatchGroup.svelte";
  import { scheduleStore } from "../../stores/ScheduleStore";

  let dropdownOpen = false;
  let data:
    | {
        matchGroups: MatchGroupDetails[];
        selectedMatchGroupIndex: number;
      }
    | undefined;

  scheduleStore.subscribeMatchGroups((matchGroups: MatchGroupDetails[]) => {
    if (matchGroups.length == 0) return;
    let selectedMatchGroupIndex = 0;
    matchGroups.forEach((matchGroup: MatchGroupDetails, i: number) => {
      if (
        matchGroup.state == "InProgress" ||
        matchGroup.state == "Scheduled" ||
        matchGroup.state == "Completed"
      ) {
        // Select the last match group that is in progress or scheduled
        selectedMatchGroupIndex = i;
      }
    });
    data = { matchGroups, selectedMatchGroupIndex };
  });
  let getDateTimeString = (nanoseconds: bigint) => {
    const options: Intl.DateTimeFormatOptions = {
      month: "short",
      day: "numeric",
      hour: "2-digit",
      minute: "2-digit",
      hour12: false,
    };
    const date = nanosecondsToDate(nanoseconds);
    return new Intl.DateTimeFormat(undefined, options).format(date);
  };
  let selectMatchGroup = (i: number) => () => {
    if (!data || i < 0 || i >= data!.matchGroups.length) return;
    data.selectedMatchGroupIndex = i;
    dropdownOpen = false;
  };
</script>

{#if data}
  <div class="flex flex-col justify-center space-between">
    <div class="flex justify-center">
      <Button
        on:click={selectMatchGroup(data.selectedMatchGroupIndex - 1)}
        disabled={data.selectedMatchGroupIndex <= 0}
      >
        <ArrowKeyLeft />
      </Button>
      <div id="dropdownTrigger" class="p-5 cursor-pointer">
        <div class="flex space-between gap-3 items-center">
          Match Group {data.selectedMatchGroupIndex + 1}
          <ArrowKeyDown />
        </div>
        <Helper helperClass="text-center">
          {getDateTimeString(
            data.matchGroups[data.selectedMatchGroupIndex].time
          )}
        </Helper>
      </div>
      <Button
        on:click={selectMatchGroup(data.selectedMatchGroupIndex + 1)}
        disabled={data.selectedMatchGroupIndex >= data.matchGroups.length - 1}
      >
        <ArrowKeyRight />
      </Button>
    </div>

    <Dropdown
      triggeredBy="#dropdownTrigger"
      class="w-48 overflow-y-auto py-1 h-64"
      activeUrl={"#" + data.selectedMatchGroupIndex}
      bind:open={dropdownOpen}
    >
      {#each data.matchGroups as matchGroup, i}
        <DropdownItem href={"#" + i} on:click={selectMatchGroup(i)}>
          <div class="text-center text-md font-bold">
            Match Group {i + 1}
          </div>
          <Helper helperClass="text-center">
            {getDateTimeString(matchGroup.time)}
          </Helper>
        </DropdownItem>
      {/each}
    </Dropdown>
    <div class="flex justify-center">
      <MatchGroup matchGroup={data.matchGroups[data.selectedMatchGroupIndex]} />
    </div>
  </div>
{/if}
