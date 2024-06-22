<script lang="ts">
    import { Label } from "flowbite-svelte";
    import BigIntInput from "../BigIntInput.svelte";
    import { toJsonString } from "../../../../utils/StringUtil";
    import ChosenOrRandomSkillChooser from "../ChosenOrRandomSkillChooser.svelte";
    import ChosenOrRandomFieldPositionChooser from "../ChosenOrRandomFieldPositionChooser.svelte";
    import { ProportionalBidScenario } from "../../../../ic-agent/declarations/league";
    export let value: ProportionalBidScenario;
</script>

<Label>Prize Amount</Label>
<BigIntInput bind:value={value.prize.amount} />
<Label>Prize Effect</Label>
{#if "skill" in value.prize.kind}
    <div class="ml-4">
        <Label>Skill</Label>
        <ChosenOrRandomSkillChooser bind:value={value.prize.kind.skill.skill} />
        <Label>Position</Label>
        <ChosenOrRandomFieldPositionChooser
            bind:value={value.prize.kind.skill.target.position}
        />
    </div>
{:else}
    NOT IMPLEMENTED PRIZE KIND : {toJsonString(value.prize.kind)}
{/if}
