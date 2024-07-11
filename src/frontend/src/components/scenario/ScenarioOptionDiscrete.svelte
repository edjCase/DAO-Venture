<script lang="ts">
    import { Badge } from "flowbite-svelte";
    import {
        ScenarioVote,
        TraitRequirement,
        VoteOnScenarioRequest,
    } from "../../ic-agent/declarations/main";
    import { teamStore } from "../../stores/TeamStore";
    import { traitStore } from "../../stores/TraitStore";
    import TeamLogo from "../team/TeamLogo.svelte";
    import {
        QuestionCircleSolid,
        ThumbsDownSolid,
        ThumbsUpSolid,
    } from "flowbite-svelte-icons";
    import { scenarioStore } from "../../stores/ScenarioStore";
    import { mainAgentFactory } from "../../ic-agent/Main";
    import { Team } from "../../ic-agent/declarations/main";

    type State =
        | {
              inProgress: {
                  onSelect: () => void;
              };
          }
        | {
              resolved: {
                  chosenByTeamIds: bigint[];
              };
          };

    export let option: {
        id: bigint;
        title: string;
        description: string;
        traitRequirements: TraitRequirement[];
    };
    export let scenarioId: bigint;
    export let currency: { teamCurrency: bigint; cost: bigint } | undefined; // Undefined used for loading but also for resolved scenarios
    export let selected: boolean;
    export let vote: ScenarioVote | "ineligible";
    export let state: State;

    $: meetsCurrencyRequirements =
        currency !== undefined && currency.cost <= currency.teamCurrency;

    $: selectable =
        "inProgress" in state &&
        vote != "ineligible" &&
        meetsCurrencyRequirements;

    $: cursorPointerClass = selectable ? "cursor-pointer" : "";
    $: disabledClass =
        "inProgress" in state &&
        currency !== undefined &&
        !meetsCurrencyRequirements
            ? "opacity-50 cursor-not-allowed"
            : "";

    let teamsWithOption: Team[] | undefined = undefined;
    teamStore.subscribe((teams) => {
        teamsWithOption = teams?.filter((t) => {
            if ("resolved" in state) {
                return state.resolved.chosenByTeamIds.includes(t.id);
            }
            return false;
        });
    });

    $: traits = $traitStore;

    $: requirements = option.traitRequirements.map((r) => {
        let name = traits?.find((t) => t.id === r.id)?.name ?? "";

        let icon:
            | typeof QuestionCircleSolid
            | typeof ThumbsDownSolid
            | typeof ThumbsUpSolid;
        let color: "none" | "red" | "green";
        if ("required" in r.kind) {
            icon = ThumbsUpSolid;
            color = "green";
        } else if ("prohibited" in r.kind) {
            icon = ThumbsDownSolid;
            color = "red";
        } else {
            icon = QuestionCircleSolid;
            color = "none";
        }

        return {
            name: name,
            icon,
            color,
        };
    });

    let voteForOption = async function () {
        if (vote === "ineligible") {
            console.error("Team is ineligible to vote for this option");
            return;
        }
        let request: VoteOnScenarioRequest = {
            scenarioId: scenarioId,
            value: { id: BigInt(option.id) },
        };
        console.log(
            `Voting for team ${vote.teamId} and scenario ${scenarioId} with option ${option.id}`,
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

    $: teamOption =
        vote === "ineligible" || !("discrete" in vote.teamOptions)
            ? undefined
            : vote.teamOptions.discrete.find((v) => v.id === BigInt(option.id));
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
        {#if currency !== undefined && currency.cost > 0}
            <div class="text-xl text-center">{currency.cost} 💰</div>
        {/if}
        {#if teamOption === undefined}
            <div class="text-center text-xl font-bold">Ineligible to vote</div>
        {:else}
            <div>
                Team Votes: {teamOption.currentVotingPower}
            </div>
        {/if}
        {#each requirements as { name, icon, color }}
            <Badge {color}>
                <svelte:component this={icon} size="xs" class="mr-2" />
                {name}
            </Badge>
        {/each}
    </div>
    {#if "resolved" in state && teamsWithOption !== undefined}
        <div class="flex items-center justify-center">
            {#each teamsWithOption as team}
                <TeamLogo {team} size="xs" />
            {/each}
        </div>
    {/if}
</div>
