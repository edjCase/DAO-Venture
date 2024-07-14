<script lang="ts">
    import { Button, Input, Label } from "flowbite-svelte";
    import BigIntInput from "./BigIntInput.svelte";
    import { Effect } from "../../../ic-agent/declarations/main";
    import { toJsonString } from "../../../utils/StringUtil";
    import TargetPositionEditor from "./TargetPositionEditor.svelte";
    import DurationChooser from "./DurationChooser.svelte";
    import { TrashBinSolid } from "flowbite-svelte-icons";
    import ScenarioEffectChooser from "./ScenarioEffectChooser.svelte";
    import TargetTeamChooser from "./TargetTeamChooser.svelte";
    import ChosenOrRandomSkillChooser from "./ChosenOrRandomSkillChooser.svelte";
    import TeamTraitEffectEditor from "./TeamTraitEffectEditor.svelte";
    export let value: Effect;

    let addOption = () => {
        if ("allOf" in value) {
            value.allOf.push({ noEffect: null });
            value.allOf = value.allOf;
        } else if ("oneOf" in value) {
            value.oneOf.push({
                weight: BigInt(1),
                effect: { noEffect: null },
                description: "",
            });
            value.oneOf = value.oneOf;
        }
    };

    let remove = (i: number) => {
        if ("allOf" in value) {
            value.allOf.splice(i, 1);
            value.allOf = value.allOf;
        } else if ("oneOf" in value) {
            value.oneOf.splice(i, 1);
            value.oneOf = value.oneOf;
        }
    };
</script>

{#if "allOf" in value}
    <div class="ml-6 border rounded">
        {#each value.allOf as innerEffect, i}
            <ScenarioEffectChooser bind:value={innerEffect} />
            <button on:click={() => remove(i)}>
                <TrashBinSolid size="sm" />
            </button>
        {/each}
        <Button on:click={addOption}>Add Option</Button>
    </div>
{:else if "oneOf" in value}
    <div class="ml-6 border rounded">
        {#each value.oneOf as innerEffect}
            <Label>Description</Label>
            <Input type="text" bind:value={innerEffect.description} />
            <Label>Weight</Label>
            <BigIntInput bind:value={innerEffect.weight} />
            <ScenarioEffectChooser bind:value={innerEffect.effect} />
        {/each}
        <Button on:click={addOption}>Add Option</Button>
    </div>
{:else if "entropy" in value}
    <Label>Amount</Label>
    <BigIntInput bind:value={value.entropy.delta} />
    <TargetTeamChooser bind:value={value.entropy.team} />
{:else if "currency" in value}
    <Label>Amount</Label>
    <BigIntInput bind:value={value.currency.value.flat} />
    <Label>Team</Label>
    <TargetTeamChooser bind:value={value.currency.team} />
{:else if "skill" in value}
    <Label>Target Position</Label>
    <div class="ml-4">
        <TargetPositionEditor bind:value={value.skill.position} />
    </div>
    <Label>Skill</Label>
    <div class="ml-4">
        <ChosenOrRandomSkillChooser bind:value={value.skill.skill} />
    </div>
    <Label>Duration</Label>
    <div class="ml-4">
        <DurationChooser bind:value={value.skill.duration} />
    </div>
    <Label>Delta</Label>
    <BigIntInput bind:value={value.skill.delta} />
{:else if "injury" in value}
    <Label>Target</Label>
    <div class="ml-4">
        <TargetPositionEditor bind:value={value.injury.position} />
    </div>
{:else if "teamTrait" in value}
    <TeamTraitEffectEditor bind:value={value.teamTrait} />
{:else if "entropyThreshold" in value}
    <Label>Delta</Label>
    <BigIntInput bind:value={value.entropyThreshold.delta} />
{:else if "leagueIncome" in value}
    <Label>Delta</Label>
    <BigIntInput bind:value={value.leagueIncome.delta} />
{:else if "noEffect" in value}
    <div></div>
{:else}
    NOT IMPLEMENTED : {toJsonString(value)}
{/if}
