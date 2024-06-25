<script lang="ts">
    import { Input, Label } from "flowbite-svelte";
    import {
        ProportionalBidScenario,
        ScenarioVote,
    } from "../../../ic-agent/declarations/league";
    import { toJsonString } from "../../../utils/StringUtil";
    import LoadingButton from "../../common/LoadingButton.svelte";
    import { leagueAgentFactory } from "../../../ic-agent/League";
    import { scenarioStore } from "../../../stores/ScenarioStore";

    export let scenarioId: bigint;
    export let scenario: ProportionalBidScenario;
    export let vote: ScenarioVote;

    let bid = 0;

    let addBid = async function () {
        if (bid < 1) {
            // TODO better error handling
            console.error("Bid amount must be a positive number");
            return;
        }
        let leagueAgent = await leagueAgentFactory();
        let result = await leagueAgent.addScenarioCustomTeamOption({
            scenarioId: scenarioId,
            value: { nat: BigInt(bid) },
        });
        if ("ok" in result) {
            console.log("Added ticket count option for scenario", scenarioId);
            scenarioStore.refetchById(scenarioId);
        } else {
            console.error(
                "Failed to add ticket count option for scenario: ",
                result,
            );
        }
    };
</script>

<Label>Prize</Label>
{scenario.prize.amount}
{#if "skill" in scenario.prize.kind}
    {scenario.prize.kind.skill.skill} for {scenario.prize.kind.skill.duration} days
{:else}
    NOT IMPLEMENTED PRIZE: {toJsonString(scenario.prize.kind)}
{/if}

<div>
    Suggest Ticket Count
    <Input type="number" bind:value={bid} />
    <LoadingButton onClick={addBid}>Submit</LoadingButton>
</div>
