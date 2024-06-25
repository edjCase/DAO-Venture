<script lang="ts">
    import { Input } from "flowbite-svelte";
    import {
        LotteryScenario,
        ScenarioVote,
    } from "../../../ic-agent/declarations/league";
    import LoadingButton from "../../common/LoadingButton.svelte";
    import { scenarioStore } from "../../../stores/ScenarioStore";
    import { leagueAgentFactory } from "../../../ic-agent/League";

    export let scenarioId: bigint;
    export let scenario: LotteryScenario;
    export let vote: ScenarioVote;

    let bid = 0;

    let addBid = async function () {
        if (bid === undefined) {
            console.error("No bid amount specified");
            return;
        }
        if (bid < scenario.minBid) {
            // TODO better error handling
            console.error("Ticket amount must be a at least ", scenario.minBid);
            return;
        }
        let leagueAgent = await leagueAgentFactory();
        let result = await leagueAgent.addScenarioCustomTeamOption({
            scenarioId: scenarioId,
            value: { nat: BigInt(bid) },
        });
        if ("ok" in result) {
            console.log("Added bid option for scenario", scenarioId);
            scenarioStore.refetchById(scenarioId);
        } else {
            console.error("Failed to add bid option for scenario: ", result);
        }
    };
</script>

<div>
    Suggest Bid Amount
    <Input type="number" bind:value={bid} />
    <LoadingButton onClick={addBid}>Submit</LoadingButton>
</div>
