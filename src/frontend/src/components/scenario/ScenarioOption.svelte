<script lang="ts">
    import { ScenarioOptionWithEffect } from "../../ic-agent/declarations/league";
    import { teamStore } from "../../stores/TeamStore";
    import TeamLogo from "../team/TeamLogo.svelte";

    type State =
        | {
              inProgress: {
                  onSelect: () => void;
              };
          }
        | {
              resolved: {
                  teams: bigint[] | undefined;
              };
          };

    export let option: ScenarioOptionWithEffect;
    export let teamEnergy: bigint | undefined;
    export let selected: boolean;
    export let voteStatus: number | "notVoted" | "ineligible";
    export let state: State;

    $: selectable =
        "inProgress" in state &&
        voteStatus === "notVoted" &&
        teamEnergy !== undefined &&
        option.energyCost <= teamEnergy;

    $: cursorPointerClass = selectable ? "cursor-pointer" : "";
    $: disabledClass =
        "inProgress" in state &&
        teamEnergy !== undefined &&
        option.energyCost > teamEnergy
            ? "opacity-50 cursor-not-allowed"
            : "";
    $: teams = $teamStore;
    $: teamsWithOption = teams?.filter((t) => {
        if ("resolved" in state && state.resolved.teams !== undefined) {
            return state.resolved.teams.includes(t.id);
        }
        return false;
    });
</script>

<div
    class="border border-gray-300 p-4 rounded-lg flex-1 text-left text-base text-white {cursorPointerClass} {disabledClass}"
    class:bg-gray-900={selected}
    class:border-gray-500={!selected}
    class:bg-gray-700={!selected}
    on:click={() => {
        if (selectable && "inProgress" in state) {
            state.inProgress.onSelect();
        }
    }}
    on:keypress={() => {}}
    role={selectable ? "button" : ""}
>
    <div class="w-full h-full">
        <div class="text-center text-xl font-bold">{option.title}</div>
        <div class="text-justify text-sm">{option.description}</div>
        {#if option.energyCost > 0}
            <div class="text-xl text-center">{option.energyCost} 💰</div>
        {/if}
    </div>
    {#if "resolved" in state && teamsWithOption !== undefined}
        <div class="flex items-center justify-center">
            {#each teamsWithOption as team}
                <TeamLogo {team} size="xs" />
            {/each}
        </div>
    {/if}
</div>
