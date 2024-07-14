<script lang="ts">
    import {
        ScenarioOptionValue,
        ScenarioTeamOptionNat,
        ScenarioTeamOptionText,
        VoteOnScenarioRequest,
    } from "../../ic-agent/declarations/main";
    import { mainAgentFactory } from "../../ic-agent/Main";
    import { teamStore } from "../../stores/TeamStore";
    import { scenarioStore } from "../../stores/ScenarioStore";
    import ScenarioOptionNat from "./ScenarioOptionNat.svelte";
    import BigIntInput from "./editors/BigIntInput.svelte";
    import LoadingButton from "../common/LoadingButton.svelte";

    export let scenarioId: bigint;
    export let teamId: bigint;
    export let kind:
        | {
              nat: {
                  options: ScenarioTeamOptionNat[];
                  proposeName: string;
                  icon: string;
                  teamCurrency: bigint | undefined;
              };
          }
        | {
              text: {
                  options: ScenarioTeamOptionText[];
              };
          };
    export let vote: ScenarioOptionValue | undefined;

    let value: ScenarioOptionValue | undefined = vote;

    let voteForNat = async function () {
        if (value === undefined) {
            console.error("No value selected");
            return;
        }
        if (teamCurrency === undefined || natValue > teamCurrency) {
            console.error("Value exceeds team currency");
            return;
        }
        let request: VoteOnScenarioRequest = {
            scenarioId: scenarioId,
            value: value,
        };
        console.log(
            `Voting for team ${teamId} and scenario ${scenarioId} with nat value ${natValue}`,
            request,
        );
        let mainAgent = await mainAgentFactory();
        let result = await mainAgent.voteOnScenario(request);
        if ("ok" in result) {
            console.log("Voted for scenario", request.scenarioId);
            teamStore.refetch();
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
        {#if options.length < 1}
            <div>-</div>
        {:else}
            {#each options as option}
                <ScenarioOptionNat
                    {option}
                    selected={vote === option.value}
                    {teamCurrency}
                    {icon}
                    onSelect={() => {
                        natValue = option.value;
                        voteForNat();
                    }}
                />
            {/each}
        {/if}
    </div>
    <div class="flex flex-col items-center justify-center">
        <div class="text-xl p-2">Propose {proposeName}</div>
        <div class="flex gap-2">
            <div class="w-20">
                <BigIntInput bind:value={natValue} />
            </div>
            <LoadingButton onClick={voteForNat}>Propose</LoadingButton>
        </div>
    </div>
</div>
