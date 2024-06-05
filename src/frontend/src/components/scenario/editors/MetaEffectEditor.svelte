<script lang="ts">
    import { Button, Input, Label } from "flowbite-svelte";
    import BigIntInput from "./BigIntInput.svelte";
    import ScenarioEffectEditor from "./ScenarioEffectEditor.svelte";
    import { MetaEffect } from "../../../ic-agent/declarations/league";
    import { toJsonString } from "../../../utils/StringUtil";
    import ScenarioEffectChooser from "./ScenarioEffectChooser.svelte";
    import ThresholdValueChooser from "./ThresholdValueChooser.svelte";
    import { TrashBinSolid } from "flowbite-svelte-icons";
    import ChosenOrRandomSkillChooser from "./ChosenOrRandomSkillChooser.svelte";
    import ChosenOrRandomFieldPositionChooser from "./ChosenOrRandomFieldPositionChooser.svelte";
    export let value: MetaEffect;

    let addOption = () => {
        if ("lottery" in value) {
            value.lottery.options.push({ tickets: BigInt(1) });
            value.lottery.options = value.lottery.options;
        } else if ("proportionalBid" in value) {
            value.proportionalBid.options.push({ bidValue: BigInt(1) });
            value.proportionalBid.options = value.proportionalBid.options;
        } else if ("leagueChoice" in value) {
            value.leagueChoice.options.push({ effect: { noEffect: null } });
            value.leagueChoice.options = value.leagueChoice.options;
        } else if ("threshold" in value) {
            value.threshold.options.push({
                value: { fixed: BigInt(1) },
            });
            value.threshold.options = value.threshold.options;
        }
    };

    let remove = (i: number) => {
        if ("lottery" in value) {
            value.lottery.options.splice(i, 1);
            value.lottery.options = value.lottery.options;
        } else if ("proportionalBid" in value) {
            value.proportionalBid.options.splice(i, 1);
            value.proportionalBid.options = value.proportionalBid.options;
        } else if ("leagueChoice" in value) {
            value.leagueChoice.options.splice(i, 1);
            value.leagueChoice.options = value.leagueChoice.options;
        } else if ("threshold" in value) {
            value.threshold.options.splice(i, 1);
            value.threshold.options = value.threshold.options;
        }
    };
</script>

{#if "lottery" in value}
    <div class="ml-4">
        {#each value.lottery.options as option, i}
            <Label>Option {i + 1} - Ticket Count</Label>
            <BigIntInput bind:value={option.tickets} />
            <button on:click={() => remove(i)}>
                <TrashBinSolid size="sm" />
            </button>
        {/each}
        <Button on:click={addOption}>Add Option</Button>
    </div>
    <Label>Prize</Label>
    <ScenarioEffectEditor bind:value={value.lottery.prize} />
{:else if "threshold" in value}
    <Label>Min Value</Label>
    <BigIntInput bind:value={value.threshold.minAmount} />

    <Label>Abstain Value</Label>
    <ThresholdValueChooser bind:value={value.threshold.abstainAmount} />

    <div class="ml-4">
        {#each value.threshold.options as option, i}
            <Label>Option {i + 1}</Label>
            <ThresholdValueChooser bind:value={option.value} />
            <button on:click={() => remove(i)}>
                <TrashBinSolid size="sm" />
            </button>
        {/each}
        <Button on:click={addOption}>Add Option</Button>
    </div>
    <Label>Success Effect</Label>
    <div class="ml-4">
        <Label>Description</Label>
        <Input type="text" bind:value={value.threshold.success.description} />
        <ScenarioEffectChooser bind:value={value.threshold.success.effect} />
    </div>
    <Label>Failure Effect</Label>
    <div class="ml-4">
        <Label>Description</Label>
        <Input type="text" bind:value={value.threshold.failure.description} />
        <ScenarioEffectChooser bind:value={value.threshold.failure.effect} />
    </div>
{:else if "proportionalBid" in value}
    <div class="ml-4">
        {#each value.proportionalBid.options as option, i}
            <Label>Option {i + 1} - Bid Value</Label>
            <BigIntInput bind:value={option.bidValue} />
            <button on:click={() => remove(i)}>
                <TrashBinSolid size="sm" />
            </button>
        {/each}
        <Button on:click={addOption}>Add Option</Button>
    </div>
    <Label>Prize Amount</Label>
    <BigIntInput bind:value={value.proportionalBid.prize.amount} />
    <Label>Prize Effect</Label>
    {#if "skill" in value.proportionalBid.prize.kind}
        <div class="ml-4">
            <ChosenOrRandomSkillChooser
                bind:value={value.proportionalBid.prize.kind.skill.skill}
            />
        </div>
        <ChosenOrRandomFieldPositionChooser
            bind:value={value.proportionalBid.prize.kind.skill.target.position}
        />
    {:else}
        NOT IMPLEMENTED PRIZE KIND : {toJsonString(
            value.proportionalBid.prize.kind,
        )}
    {/if}
{:else if "leagueChoice" in value}
    <div class="ml-4">
        {#each value.leagueChoice.options as option, i}
            <Label>Option {i + 1} - Effect</Label>
            <ScenarioEffectChooser bind:value={option.effect} />
            <button on:click={() => remove(i)}>
                <TrashBinSolid size="sm" />
            </button>
        {/each}
        <Button on:click={addOption}>Add Option</Button>
    </div>
{:else if "noEffect" in value}
    <div></div>
{:else}
    NOT IMPLEMENTED META EFFECT : {toJsonString(value)}
{/if}
