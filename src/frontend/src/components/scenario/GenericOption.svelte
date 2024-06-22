<script lang="ts">
    import { Badge } from "flowbite-svelte";
    import {
        ScenarioVote,
        TraitRequirement,
        VoteOnScenarioRequest,
    } from "../../ic-agent/declarations/league";
    import { teamStore } from "../../stores/TeamStore";
    import { traitStore } from "../../stores/TraitStore";
    import { toJsonString } from "../../utils/StringUtil";
    import TeamLogo from "../team/TeamLogo.svelte";
    import {
        QuestionCircleSolid,
        ThumbsDownSolid,
        ThumbsUpSolid,
    } from "flowbite-svelte-icons";
    import { scenarioStore } from "../../stores/ScenarioStore";
    import { leagueAgentFactory } from "../../ic-agent/League";

    type State =
        | {
              inProgress: {
                  onSelect: () => void;
              };
          }
        | {
              resolved: {
                  teams: bigint[] | undefined;
              };
          };

    export let optionId: number;
    export let scenarioId: bigint;
    export let teamEnergy: bigint | undefined; // Undefined used for loading but also for resolved scenarios
    export let teamTraits: string[] | undefined; // Undefined used for loading but also for resolved scenarios
    export let selected: boolean;
    export let traitRequirements: TraitRequirement[];
    export let energyCost: bigint;
    export let vote: ScenarioVote | "ineligible";
    export let state: State;

    let badTraits: Map<string, boolean> = new Map();
    $: {
        badTraits.clear();
        if (teamTraits) {
            let traits = teamTraits;
            traitRequirements.forEach((r) => {
                let hasTrait = traits.indexOf(r.id) >= 0;
                if ("required" in r.kind) {
                    if (!hasTrait) {
                        badTraits.set(r.id, true);
                    }
                } else if ("prohibited" in r.kind) {
                    if (hasTrait) {
                        badTraits.set(r.id, false);
                    }
                } else {
                    throw (
                        "Trait requirement check not implemented for kind: " +
                        toJsonString(r.kind)
                    );
                }
            });
        }
    }

    $: meetsEnergyRequirements =
        teamEnergy !== undefined && energyCost <= teamEnergy;

    $: selectable =
        "inProgress" in state &&
        vote != "ineligible" &&
        meetsEnergyRequirements &&
        badTraits.size < 1;

    $: cursorPointerClass = selectable ? "cursor-pointer" : "";
    $: disabledClass =
        "inProgress" in state &&
        teamEnergy !== undefined &&
        (!meetsEnergyRequirements || badTraits.size > 0)
            ? "opacity-50 cursor-not-allowed"
            : "";
    $: teams = $teamStore;
    $: teamsWithOption = teams?.filter((t) => {
        if ("resolved" in state && state.resolved.teams !== undefined) {
            return state.resolved.teams.includes(t.id);
        }
        return false;
    });

    $: traits = $traitStore;

    $: requirements = traitRequirements.map((r) => {
        let name = traits?.find((t) => t.id === r.id)?.name ?? "";
        let icon: typeof ThumbsUpSolid | typeof ThumbsDownSolid;
        let meetsRequirement: boolean | undefined;

        if ("required" in r.kind) {
            icon = ThumbsUpSolid;
            meetsRequirement =
                teamTraits !== undefined
                    ? teamTraits.indexOf(r.id) >= 0
                    : undefined;
        } else if ("prohibited" in r.kind) {
            icon = ThumbsDownSolid;
            meetsRequirement =
                teamTraits !== undefined
                    ? teamTraits.indexOf(r.id) < 0
                    : undefined;
        } else {
            icon = QuestionCircleSolid;
            meetsRequirement = false;
        }
        let color: "none" | "green" | "red";
        if (meetsRequirement === undefined) {
            color = "none";
        } else {
            color = meetsRequirement ? "green" : "red";
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
            option: BigInt(optionId),
        };
        console.log(
            `Voting for team ${vote.teamId} and scenario ${scenarioId} with option ${optionId}`,
            request,
        );
        let leagueAgent = await leagueAgentFactory();
        let result = await leagueAgent.voteOnScenario(request);
        if ("ok" in result) {
            console.log("Voted for scenario", request.scenarioId);
            teamStore.refetch();
            scenarioStore.refetchVotes([scenarioId]);
        } else {
            console.error("Failed to vote for match: ", result);
        }
    };
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
        <slot />
        {#if vote === "ineligible"}
            <div class="text-center text-xl font-bold">Ineligible to vote</div>
        {:else}
            <div>
                Team Votes: {vote.optionVotingPowersForTeam[optionId]}
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
