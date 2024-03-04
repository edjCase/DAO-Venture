<script lang="ts">
    import { ResolvedScenario } from "../../ic-agent/declarations/league";

    export let scenario: ResolvedScenario;

    let selectedChoice: number | undefined;
</script>

<div>
    <div class="p-5 pt-0">
        {@html scenario.description}
    </div>
    <div class="flex flex-col items-center gap-2">
        {#each scenario.options as { title, description }, index}
            <div
                class="border border-gray-300 p-4 rounded-lg flex-1 cursor-pointer text-left w-96 text-base text-white"
                class:bg-gray-500={selectedChoice === index}
                class:border-gray-500={selectedChoice === index}
                class:bg-gray-800={selectedChoice !== index}
                on:click={() => {
                    selectedChoice = index;
                }}
                on:keypress={() => {}}
                role="button"
                tabindex={index}
            >
                <div class="font-bold">{@html title}</div>
                <div class="">
                    {@html description}
                </div>
            </div>
        {/each}
    </div>
</div>
