<script lang="ts">
    import {
        ScenarioOption,
        ScenarioStateResolved,
    } from "../../ic-agent/declarations/league";
    import { User } from "../../ic-agent/declarations/users";

    export let state: ScenarioStateResolved;
    export let options: ScenarioOption[];
    export let userContext: User | undefined;

    let selectedChoice: number | undefined;
    $: {
        let vote = state.teamChoices.find(
            (v) => v.teamId === userContext?.team[0]?.id,
        );
        if (vote) {
            selectedChoice = Number(vote.option);
        }
    }
</script>

{#each options as { description }, index}
    <div
        class="border border-gray-300 p-4 rounded-lg flex-1 cursor-pointer text-left text-base text-white"
        class:bg-gray-500={selectedChoice === index}
        class:border-gray-500={selectedChoice === index}
        class:bg-gray-800={selectedChoice !== index}
    >
        <div class="">
            {@html description}
        </div>
    </div>
{/each}
