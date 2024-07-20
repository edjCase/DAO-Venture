<script lang="ts">
    import { ScenarioTownOptionNat } from "../../ic-agent/declarations/main";

    export let option: ScenarioTownOptionNat;
    export let townCurrency: bigint | undefined; // Undefined used for loading but also for resolved scenarios
    export let selected: boolean;
    export let icon: string;
    export let onSelect: () => void;

    $: meetsCurrencyRequirements =
        townCurrency !== undefined && option.value <= townCurrency;

    $: selectable = meetsCurrencyRequirements;

    $: cursorPointerClass = selectable ? "cursor-pointer" : "";
    $: disabledClass =
        townCurrency !== undefined && !meetsCurrencyRequirements
            ? "opacity-50 cursor-not-allowed"
            : "";
</script>

<div
    class="border border-gray-300 rounded-lg text-left text-base text-white {cursorPointerClass} {disabledClass} mb-2"
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
    <div class="flex items-center justify-between py-2">
        <div class="text-center text-xl font-bold px-6">
            {option.value}
            {icon}
        </div>
        <div class="px-6">
            Town: {option.currentVotingPower}
        </div>
    </div>
</div>
