<script lang="ts">
    import {
        ScenarioOptionValue,
        ScenarioTownOptionNat,
        ScenarioTownOptionText,
        VoteOnScenarioRequest,
    } from "../../ic-agent/declarations/main";
    import { mainAgentFactory } from "../../ic-agent/Main";
    import { townStore } from "../../stores/TownStore";
    import { scenarioStore } from "../../stores/ScenarioStore";
    import ScenarioOptionNat from "./ScenarioOptionNat.svelte";
    import BigIntInput from "./editors/BigIntInput.svelte";
    import LoadingButton from "../common/LoadingButton.svelte";
    import { toJsonString } from "../../utils/StringUtil";
    import ScenarioOptionText from "./ScenarioOptionText.svelte";
    import { Input } from "flowbite-svelte";
    export let scenarioId: bigint;
    export let townId: bigint;
    export let proposeName: string;
    export let kind:
        | {
              nat: {
                  options: ScenarioTownOptionNat[];
                  icon: string;
                  townResourceAmount: bigint | undefined;
                  vote: bigint | undefined;
              };
          }
        | {
              text: {
                  options: ScenarioTownOptionText[];
                  vote: string | undefined;
              };
          };

    let value: bigint | string | undefined;
    if ("nat" in kind) {
        value = kind.nat.vote;
    } else if ("text" in kind) {
        value = kind.text.vote;
    } else {
        throw new Error("Invalid scenario option kind: " + toJsonString(kind));
    }

    let voteForValue = async function () {
        if (value === undefined) {
            console.error("No value selected");
            return;
        }
        let optionValue: ScenarioOptionValue;
        if ("nat" in kind) {
            if (typeof value !== "bigint") {
                console.error("Invalid value. Expected nat value, got:", value);
                return;
            }
            if (
                kind.nat.townResourceAmount === undefined ||
                value > kind.nat.townResourceAmount
            ) {
                console.error("Value exceeds town resource");
                return;
            }
            optionValue = { nat: value };
        } else if ("text" in kind) {
            if (typeof value !== "string") {
                console.error(
                    "Invalid value. Expected text value, got:",
                    value,
                );
                return;
            }
            if (!value || !value.trim()) {
                console.error("Text value is empty");
                return;
            }
            optionValue = { text: value };
        } else {
            throw new Error("Invalid kind: " + toJsonString(kind));
        }
        let request: VoteOnScenarioRequest = {
            scenarioId: scenarioId,
            value: optionValue,
        };
        console.log(
            `Voting for town ${townId} and scenario ${scenarioId} with value:`,
            value,
            request,
        );
        let mainAgent = await mainAgentFactory();
        let result = await mainAgent.voteOnScenario(request);
        if ("ok" in result) {
            console.log("Voted for scenario", request.scenarioId);
            townStore.refetch();
            scenarioStore.refetchVotes([scenarioId]);
        } else {
            console.error("Failed to vote for match: ", result);
        }
    };
</script>

<div class="text-3xl">Proposed {proposeName}</div>
<div
    class="flex flex-col items-center justify-center border-2 border-gray-700 p-2 rounded"
>
    <div class="flex flex-col item-center justify-center min-h-48">
        {#if "nat" in kind}
            {#if kind.nat.options.length < 1}
                <div>-</div>
            {:else}
                {#each kind.nat.options as option}
                    <ScenarioOptionNat
                        {option}
                        selected={kind.nat.vote === option.value}
                        townResourceAmount={kind.nat.townResourceAmount}
                        icon={kind.nat.icon}
                        onSelect={() => {
                            value = option.value;
                            voteForValue();
                        }}
                    />
                {/each}
            {/if}
        {:else if "text" in kind}
            {#if kind.text.options.length < 1}
                <div>-</div>
            {:else}
                {#each kind.text.options as option}
                    <ScenarioOptionText
                        {option}
                        selected={kind.text.vote === option.value}
                        onSelect={() => {
                            value = option.value;
                            voteForValue();
                        }}
                    />
                {/each}
            {/if}
        {:else}
            NOT IMPLEMENTED SCENARIO OPTION KIND: {toJsonString(kind)}
        {/if}
    </div>
    <div class="flex flex-col items-center justify-center">
        <div class="text-xl p-2">Propose {proposeName}</div>
        <div class="flex gap-2">
            <div class="w-20">
                {#if "nat" in kind}
                    {#if typeof value !== "string"}
                        <BigIntInput bind:value />
                    {:else}
                        BAD STATE VALUE: {toJsonString(value)}
                    {/if}
                {:else if "text" in kind}
                    {#if typeof value !== "bigint"}
                        <Input type="text" bind:value />
                    {:else}
                        BAD STATE VALUE: {toJsonString(value)}
                    {/if}
                {:else}
                    NOT IMPLEMENTED SCENARIO OPTION KIND: {toJsonString(kind)}
                {/if}
            </div>
            <LoadingButton onClick={voteForValue}>Propose</LoadingButton>
        </div>
    </div>
</div>
