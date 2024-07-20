<script lang="ts">
    import { ScenarioTownOptionText } from "../../ic-agent/declarations/main";

    export let option: ScenarioTownOptionText;
    export let selected: boolean;
    export let onSelect: () => void;
</script>

<div
    class="border border-gray-300 rounded-lg text-left text-base text-white cursor-pointer mb-2"
    class:bg-gray-900={selected}
    class:border-gray-500={!selected}
    class:bg-gray-700={!selected}
    on:click={() => {
        onSelect();
    }}
    on:keypress={() => {}}
    role="button"
    tabindex="0"
>
    <div class="flex items-center justify-between py-2">
        <div class="text-center text-xl font-bold px-6">
            {option.value}
        </div>
        <div class="px-6">
            Town: {option.currentVotingPower}
        </div>
    </div>
</div>
