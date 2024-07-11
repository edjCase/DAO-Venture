<script lang="ts">
    import { Timeline, TimelineItem } from "flowbite-svelte";
    import { scenarioStore } from "../../stores/ScenarioStore";
    import SectionWithOverview from "../common/SectionWithOverview.svelte";
    import { nanosecondsToDate } from "../../utils/DateUtils";
    import { onDestroy } from "svelte";
    import { Scenario } from "../../ic-agent/declarations/main";
    import ScenarioComponent from "./Scenario.svelte";

    let scenarios: Scenario[] | undefined;

    let refreshVotes = (scenariosToRefresh: Scenario[]) => {
        if (scenariosToRefresh && scenariosToRefresh.length > 0) {
            scenarioStore.refetchVotes(
                scenariosToRefresh.map((s) => s.id), // TODO only do recent scenarios? that are on the page
            );
        }
    };

    scenarioStore.subscribe((s) => {
        if (s === undefined) {
            return;
        }
        if (scenarios === undefined) {
            refreshVotes(s); // Initial refresh
        }
        scenarios = s;
        scenarios?.sort(
            (s1, s2) => Number(s2.startTime) - Number(s1.startTime),
        ); // Order by start time
    });

    $: activeScenarios = scenarios?.filter(
        (scenario) => "inProgress" in scenario.state,
    );

    let interval: NodeJS.Timeout | undefined = setInterval(() => {
        if (activeScenarios) {
            refreshVotes(activeScenarios);
        }
        scenarioStore.refetch();
    }, 3000); // Refetch votes every 3 seconds

    onDestroy(() => {
        if (interval) {
            clearInterval(interval);
        }
    });
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
                    Each choice has a tradeoffs of entropy, currency, skills and
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
        {#if scenarios}
            {#each scenarios as scenario}
                <TimelineItem
                    date={nanosecondsToDate(scenario.startTime).toDateString()}
                >
                    <div class="border-2 border-gray-700 p-2 pt-0 rounded">
                        <ScenarioComponent {scenario} />
                    </div>
                </TimelineItem>
            {/each}
        {/if}
    </Timeline>
</SectionWithOverview>
