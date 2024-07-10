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
  import { nanosecondsToDate } from "../../utils/DateUtils";
  import MatchGroup from "../match/MatchGroup.svelte";
  import { scheduleStore } from "../../stores/ScheduleStore";
  import { InProgressSeasonMatchGroupVariant } from "../../ic-agent/declarations/main";

  let dropdownOpen = false;
  let data:
    | {
        matchGroups: InProgressSeasonMatchGroupVariant[];
        selectedMatchGroupIndex: number;
      }
    | undefined;

  scheduleStore.subscribeMatchGroups(
    (matchGroups: InProgressSeasonMatchGroupVariant[]) => {
      if (matchGroups.length == 0) return;

      // Select the last match group that is in progress or scheduled
      let selectedMatchGroupIndex = matchGroups.findLastIndex(
        (matchGroup: InProgressSeasonMatchGroupVariant) => {
          return (
            "inProgress" in matchGroup ||
            "scheduled" in matchGroup ||
            "completed" in matchGroup
          );
        },
      );
      data = { matchGroups, selectedMatchGroupIndex };
    },
  );
  let getDateTimeString = (matchGroup: InProgressSeasonMatchGroupVariant) => {
    let nanoseconds;
    if ("inProgress" in matchGroup) {
      nanoseconds = matchGroup.inProgress.time;
    } else if ("scheduled" in matchGroup) {
      nanoseconds = matchGroup.scheduled.time;
    } else if ("completed" in matchGroup) {
      nanoseconds = matchGroup.completed.time;
    } else {
      return "";
    }
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
          {getDateTimeString(data.matchGroups[data.selectedMatchGroupIndex])}
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
      {#each data.matchGroups as matchGroup, matchGroupId}
        <DropdownItem
          href={"#" + matchGroupId}
          on:click={selectMatchGroup(matchGroupId)}
        >
          <div class="text-center text-md font-bold">
            Match Group {matchGroupId + 1}
          </div>
          <Helper helperClass="text-center">
            {getDateTimeString(matchGroup)}
          </Helper>
        </DropdownItem>
      {/each}
    </Dropdown>
    <div class="flex justify-center">
      <MatchGroup
        matchGroupId={data.selectedMatchGroupIndex}
        matchGroup={data.matchGroups[data.selectedMatchGroupIndex]}
        lastMatchGroup={data.matchGroups.findLast((mg) => "completed" in mg)
          ?.completed}
      />
    </div>
  </div>
{/if}
