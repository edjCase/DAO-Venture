<script lang="ts">
    import { Badge } from "flowbite-svelte";
    import {
        ScenarioVote,
        Requirement,
        VoteOnScenarioRequest,
        RangeRequirement,
        ResourceKind,
    } from "../../ic-agent/declarations/main";
    import { townStore } from "../../stores/TownStore";
    import TownFlag from "../town/TownFlag.svelte";
    import { scenarioStore } from "../../stores/ScenarioStore";
    import { mainAgentFactory } from "../../ic-agent/Main";
    import { Town } from "../../ic-agent/declarations/main";
    import { toJsonString } from "../../utils/StringUtil";
    import ResourceIcon from "../icons/ResourceIcon.svelte";

    type State =
        | {
              inProgress: {
                  onSelect: () => void;
              };
          }
        | {
              resolved: {
                  chosenByTownIds: bigint[];
              };
          };

    export let option: {
        id: bigint;
        title: string;
        description: string;
        requirements: Requirement[];
    };
    export let scenarioId: bigint;
    export let resourceCosts: {
        kind: ResourceKind;
        cost: bigint;
        townAmount: bigint | undefined;
    }[]; // Undefined used for loading but also for resolved scenarios
    export let selected: boolean;
    export let vote: ScenarioVote | "ineligible";
    export let state: State;

    $: meetsCostRequirements = resourceCosts.every(
        (r) => r.townAmount === undefined || r.cost <= r.townAmount,
    );

    $: selectable =
        "inProgress" in state && vote != "ineligible" && meetsCostRequirements;

    $: cursorPointerClass = selectable ? "cursor-pointer" : "";
    $: disabledClass =
        "inProgress" in state && !meetsCostRequirements
            ? "opacity-50 cursor-not-allowed"
            : "";

    let townsWithOption: Town[] | undefined = undefined;
    townStore.subscribe((towns) => {
        townsWithOption = towns?.filter((t) => {
            if ("resolved" in state) {
                return state.resolved.chosenByTownIds.includes(t.id);
            }
            return false;
        });
    });

    let getRangeText = function (range: RangeRequirement) {
        if ("above" in range) {
            return `Above ${range.above}`;
        } else if ("below" in range) {
            return `Below ${range.below}`;
        } else {
            return "NOT IMPLEMENTED RANGE: " + toJsonString(range);
        }
    };

    $: requirements = option.requirements.map((r) => {
        let label;
        let color:
            | "red"
            | "yellow"
            | "green"
            | "indigo"
            | "purple"
            | "pink"
            | "blue"
            | "dark"
            | "primary";
        if ("size" in r) {
            label = "Size: " + getRangeText(r.size);
            color = "dark";
        } else if ("resource" in r) {
            let name: string;
            if ("gold" in r.resource.kind) {
                name = "🪙";
            } else if ("wood" in r.resource.kind) {
                name = "🪵";
            } else if ("stone" in r.resource.kind) {
                name = "🪨";
            } else if ("food" in r.resource.kind) {
                name = "🥕";
            } else {
                name =
                    "NOT IMPLEMENTED RESOURCE: " +
                    toJsonString(r.resource.kind);
            }
            label = name + ": " + getRangeText(r.resource.range);
            color = "green";
        } else if ("age" in r) {
            label = "Age: " + getRangeText(r.age);
            color = "purple";
        } else {
            label = "NOT IMPLEMENTED REQUIREMENT: " + toJsonString(r);
            color = "red";
        }

        return {
            label,
            color,
        };
    });

    let voteForOption = async function () {
        if (vote === "ineligible") {
            console.error("Town is ineligible to vote for this option");
            return;
        }
        let request: VoteOnScenarioRequest = {
            scenarioId: scenarioId,
            value: { id: BigInt(option.id) },
        };
        console.log(
            `Voting for town ${vote.townId} and scenario ${scenarioId} with option ${option.id}`,
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

    $: townOption =
        vote === "ineligible" || !("discrete" in vote.townOptions)
            ? undefined
            : vote.townOptions.discrete.find((v) => v.id === BigInt(option.id));
</script>

<div
    class="border border-gray-300 p-4 rounded-lg flex-1 text-left text-base text-white {cursorPointerClass} {disabledClass}"
    class:bg-gray-900={selected}
    class:border-gray-500={!selected}
    class:bg-gray-700={!selected}
    on:click={() => {
        if (selectable && "inProgress" in state) {
            state.inProgress.onSelect();
            voteForOption();
        }
    }}
    on:keypress={() => {}}
    role={selectable ? "button" : ""}
>
    <div class="w-full h-full">
        <div class="text-center text-xl font-bold">{option.title}</div>
        <div class="text-justify text-sm">{option.description}</div>
        {#each resourceCosts as resourceCost}
            <div class="text-xl text-center">
                <ResourceIcon kind={resourceCost.kind} />
                {resourceCost.cost}
            </div>
        {/each}
        {#if townOption === undefined}
            <div class="text-center text-xl font-bold">Ineligible to vote</div>
        {:else}
            <div>
                Town Votes: {townOption.currentVotingPower}
            </div>
        {/if}
        {#each requirements as { label, color }}
            <Badge {color}>
                {label}
            </Badge>
        {/each}
    </div>
    {#if "resolved" in state && townsWithOption !== undefined}
        <div class="flex items-center justify-center">
            {#each townsWithOption as town}
                <TownFlag {town} size="xs" />
            {/each}
        </div>
    {/if}
</div>
