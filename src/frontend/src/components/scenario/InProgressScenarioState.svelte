<script lang="ts">
    import { Button } from "flowbite-svelte";
    import { Scenario, ScenarioVote } from "../../ic-agent/declarations/league";
    import { User } from "../../ic-agent/declarations/users";
    import { scenarioStore } from "../../stores/ScenarioStore";
    import LotteryInProgressScenarioState from "./in_progress_states/LotteryInProgressScenarioState.svelte";
    import LeagueChoiceInProgressScenarioState from "./in_progress_states/LeagueChoiceInProgressScenarioState.svelte";
    import ThresholdInProgressScenarioState from "./in_progress_states/ThresholdInProgressScenarioState.svelte";
    import NoLeagueEffectInProgressScenarioState from "./in_progress_states/NoLeagueEffectInProgressScenarioState.svelte";
    import { toJsonString } from "../../utils/StringUtil";
    import ProportionalBidInProgressScenarioState from "./in_progress_states/ProportionalBidInProgressScenarioState.svelte";
    import { teamStore } from "../../stores/TeamStore";
    import { Team } from "../../ic-agent/declarations/teams";
    import ScenarioOptionDiscrete from "./ScenarioOptionDiscrete.svelte";
    import ScenarioOptionsNat from "./ScenarioOptionsNat.svelte";

    export let scenario: Scenario;
    export let userContext: User | undefined;

    let teamId: bigint | undefined;
    let team: Team | undefined;
    let isOwner: boolean = false;

    $: teams = $teamStore;

    $: {
        teamId = userContext?.team[0]?.id;
        team = teams?.find((team) => team.id === teamId);
        isOwner = teamId != undefined && "owner" in userContext!.team[0]!.kind;
    }

    let vote: ScenarioVote | "ineligible" = "ineligible";

    let selectedId: bigint | undefined;
    let selectedNat: bigint | undefined;

    scenarioStore.subscribeVotes((votes) => {
        if (votes[Number(scenario.id)] !== undefined) {
            vote = votes[Number(scenario.id)];
            selectedId =
                vote.value[0] !== undefined && "id" in vote.value[0]
                    ? vote.value[0].id
                    : undefined;
            selectedNat =
                vote.value[0] !== undefined && "nat" in vote.value[0]
                    ? vote.value[0].nat
                    : undefined;
        } else {
            vote = "ineligible";
            selectedId = undefined;
            selectedNat = undefined;
        }
    });
</script>

{#if vote === "ineligible"}
    Ineligible to vote
    {#if !userContext || !isOwner}
        <div>Want to participate in scenarios?</div>
        <Button>Become a Team co-owner</Button>
    {/if}
{:else}
    {#if "lottery" in scenario.kind}
        <LotteryInProgressScenarioState scenario={scenario.kind.lottery} />
    {:else if "proportionalBid" in scenario.kind}
        <ProportionalBidInProgressScenarioState
            scenario={scenario.kind.proportionalBid}
        />
    {:else if "leagueChoice" in scenario.kind}
        <LeagueChoiceInProgressScenarioState />
    {:else if "threshold" in scenario.kind}
        <ThresholdInProgressScenarioState scenario={scenario.kind.threshold} />
    {:else if "noLeagueEffect" in scenario.kind}
        <NoLeagueEffectInProgressScenarioState />
    {:else}
        NOT IMPLEMENTED SCENARIO KIND: {toJsonString(scenario.kind)}
    {/if}
    {#if "nat" in vote.teamOptions}
        <ScenarioOptionsNat
            scenarioId={scenario.id}
            teamId={vote.teamId}
            options={vote.teamOptions.nat}
            teamEnergy={team === undefined ? undefined : team.energy}
            vote={selectedNat}
        />
    {:else if "discrete" in vote.teamOptions}
        {#each vote.teamOptions.discrete as option}
            <ScenarioOptionDiscrete
                scenarioId={scenario.id}
                {option}
                selected={selectedId === option.id}
                energy={team === undefined
                    ? undefined
                    : { cost: option.energyCost, teamEnergy: team.energy }}
                {vote}
                state={{
                    inProgress: {
                        onSelect: () => {
                            selectedId = option.id;
                        },
                    },
                }}
            />
        {/each}
    {:else}
        NOT IMPLEMENTED TEAM OPTIONS KIND: {toJsonString(vote.teamOptions)}
    {/if}
{/if}
