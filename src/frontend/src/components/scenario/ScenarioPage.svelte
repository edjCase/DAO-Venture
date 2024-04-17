<script lang="ts">
    import { Timeline, TimelineItem } from "flowbite-svelte";
    import { scenarioStore } from "../../stores/ScenarioStore";
    import Scenario from "./Scenario.svelte";
    import CollapsedOverview from "../common/CollapsedOverview.svelte";
    import { nanosecondsToDate } from "../../utils/DateUtils";

    $: scenarios = $scenarioStore;

    $: if (scenarios.length > 0) {
        scenarioStore.refetchVotes(
            scenarios.filter((s) => "inProgress" in s.state).map((s) => s.id),
        ); // TODO better way?
        scenarios.sort((s1, s2) => Number(s2.startTime) - Number(s1.startTime)); // Order by start time
    }
</script>

<CollapsedOverview title="Scenarios">
    <section class="p-6">
        <div class="bg-gray-700 p-4 rounded-lg shadow mb-6">
            <ul class="list-disc list-inside text-sm space-y-1">
                <li>
                    Scenarios are a way to <strong
                        >interact with the league</strong
                    > and influence the outcome of matches
                </li>
                <li>
                    Each choice has a tradeoffs of entropy, energy, skills and
                    more
                </li>
                <li>
                    Entropy: The measure of chaos in the team and league. 0 is
                    ordered and any additional value is more chaotic Too much
                    entropy can negatively affect the team and if the total
                    entropy of the league exceeds the threshold, the league will
                    collapse
                </li>
                <li>
                    Energy: The energy of the team. It can be used as a currency
                    for scenarios and training the team
                </li>
            </ul>
        </div>
    </section>
</CollapsedOverview>

<Timeline>
    {#each scenarios as scenario}
        <TimelineItem
            date={nanosecondsToDate(scenario.startTime).toDateString()}
        >
            <Scenario {scenario} />
        </TimelineItem>
    {/each}
</Timeline>
