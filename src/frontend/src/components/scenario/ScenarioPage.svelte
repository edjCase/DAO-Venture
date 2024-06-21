<script lang="ts">
    import { Timeline, TimelineItem } from "flowbite-svelte";
    import { scenarioStore } from "../../stores/ScenarioStore";
    import Scenario from "./Scenario.svelte";
    import SectionWithOverview from "../common/SectionWithOverview.svelte";
    import { nanosecondsToDate } from "../../utils/DateUtils";

    $: scenarios = $scenarioStore;

    $: if (scenarios.length > 0) {
        scenarioStore.refetchVotes(
            scenarios.map((s) => s.id), // TODO only do recent scenarios? that are on the page
        );
        scenarios.sort((s1, s2) => Number(s2.startTime) - Number(s1.startTime)); // Order by start time
    }
</script>

<SectionWithOverview title="Scenarios">
    <section slot="details" class="p-6">
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
                    🔥: The measure of chaos in the team and league. 0 is
                    ordered and any additional value is more chaotic Too much
                    entropy can negatively affect the team and if the total
                    entropy of the league exceeds the threshold, the league will
                    collapse
                </li>
                <li>
                    💰: The money of the team. It can be used as a currency for
                    scenarios and training the team
                </li>
            </ul>
        </div>
    </section>

    <Timeline>
        {#each scenarios as scenario}
            <TimelineItem
                date={nanosecondsToDate(scenario.startTime).toDateString()}
            >
                <div class="border-2 border-gray-700 p-2 pt-0 rounded">
                    <Scenario {scenario} />
                </div>
            </TimelineItem>
        {/each}
    </Timeline>
</SectionWithOverview>
