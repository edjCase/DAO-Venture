<script lang="ts">
    import { ScenarioTeamOptionNat } from "../../ic-agent/declarations/main";

    export let option: ScenarioTeamOptionNat;
    export let teamEnergy: bigint | undefined; // Undefined used for loading but also for resolved scenarios
    export let selected: boolean;
    export let onSelect: () => void;

    $: meetsEnergyRequirements =
        teamEnergy !== undefined && option.value <= teamEnergy;

    $: selectable = meetsEnergyRequirements;

    $: cursorPointerClass = selectable ? "cursor-pointer" : "";
    $: disabledClass =
        teamEnergy !== undefined && !meetsEnergyRequirements
            ? "opacity-50 cursor-not-allowed"
            : "";
</script>

<div
    class="border border-gray-300 p-4 rounded-lg flex-1 text-left text-base text-white {cursorPointerClass} {disabledClass}"
    class:bg-gray-900={selected}
    class:border-gray-500={!selected}
    class:bg-gray-700={!selected}
    on:click={() => {
        if (selectable) {
            onSelect();
        }
    }}
    on:keypress={() => {}}
    role={selectable ? "button" : ""}
>
    <div class="w-full h-full">
        <div class="text-center text-xl font-bold">{option.value}</div>
        <div class="text-xl text-center">{option.value} 💰</div>
        <div>
            Team Votes: {option.currentVotingPower}
        </div>
    </div>
</div>
