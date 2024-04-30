<script lang="ts">
    import {
        Duration,
        EffectOutcome,
        ScenarioOptionWithEffect,
        ScenarioStateResolved,
        TargetInstance,
        TargetPositionInstance,
    } from "../../ic-agent/declarations/league";
    import { Accordion, AccordionItem } from "flowbite-svelte";
    import {
        ChevronDoubleDownOutline,
        ChevronDoubleUpOutline,
    } from "flowbite-svelte-icons";
    import { User } from "../../ic-agent/declarations/users";
    import { teamStore } from "../../stores/TeamStore";
    import { toJsonString } from "../../utils/StringUtil";
    import TeamLogo from "../team/TeamLogo.svelte";
    import { skillToString } from "../../models/Skill";
    import { fieldPositionToString } from "../../models/FieldPosition";

    export let state: ScenarioStateResolved;
    export let options: ScenarioOptionWithEffect[];
    export let userContext: User | undefined;

    let selectedChoice: number | undefined;
    $: {
        let vote = state.teamChoices.find(
            (v) => v.teamId === userContext?.team[0]?.id,
        );
        if (vote) {
            selectedChoice = Number(vote.option);
        }
    }

    $: teams = $teamStore;

    $: teamChoices = state.teamChoices.map((teamChoice) => {
        let team = teams?.find((team) => team.id === teamChoice.teamId);
        return {
            team: team,
            option: Number(teamChoice.option),
        };
    });

    const getGainOrLossOutcomeText = (
        prefix: string,
        value: bigint | number,
        suffix: string,
    ) => {
        if (typeof value === "bigint") {
            value = Number(value);
        }
        let absValue = Math.abs(value);
        let gainOrLoss = value >= 0 ? "+" : "-";
        return `${prefix}: ${gainOrLoss}${absValue} ${suffix}`;
    };

    const getTeamName = (teamId: bigint) => {
        return teams?.find((team) => team.id === teamId)?.name ?? "???";
    };

    const getPositionText = (position: TargetPositionInstance) => {
        let positionText = fieldPositionToString(position.position);
        return positionText + " for Team " + getTeamName(position.teamId);
    };

    const getTargetText = (target: TargetInstance) => {
        if ("teams" in target) {
            if (target.teams.length === 0) {
                return `No Teams`;
            }
            if (target.teams.length === 1) {
                return `Team ${getTeamName(target.teams[0])}`;
            }
            let teamsText = target.teams
                .map((team) => getTeamName(team))
                .join(", ");
            return `Teams ${teamsText}`;
        } else if ("positions" in target) {
            if (target.positions.length === 0) {
                return `No Positions`;
            }
            if (target.positions.length === 1) {
                let positionText = getPositionText(target.positions[0]);
                return `Position ${positionText}`;
            }
            let positionsText = target.positions
                .map(getPositionText)
                .join(", ");
            return `Positions ${positionsText}`;
        } else if ("league" in target) {
            return "League";
        }
        return "NOT IMPLEMENTED: " + toJsonString(target);
    };

    const getDurationText = (duration: Duration) => {
        if ("indefinite" in duration) {
            return "indefinitely";
        }
        if ("matches" in duration) {
            return `for ${duration.matches} ${duration.matches === BigInt(1) ? "match" : "matches"}`;
        }
    };

    const getOutcomeText = (outcome: EffectOutcome) => {
        if ("energy" in outcome) {
            let teamName = getTeamName(outcome.energy.teamId);
            return getGainOrLossOutcomeText(
                `${teamName}`,
                outcome.energy.delta,
                "💰",
            );
        } else if ("entropy" in outcome) {
            let teamName = getTeamName(outcome.entropy.teamId);
            return getGainOrLossOutcomeText(
                `${teamName}`,
                outcome.entropy.delta,
                "🔥",
            );
        } else if ("skill" in outcome) {
            let targetName = getTargetText(outcome.skill.target);
            let skillName = skillToString(outcome.skill.skill);
            let duration = getDurationText(outcome.skill.duration);
            return getGainOrLossOutcomeText(
                targetName,
                outcome.skill.delta,
                `'${skillName}' skill ${duration}`,
            );
        }
        return "NOT IMPLEMENTED: " + toJsonString(outcome);
    };
</script>

{#each options as { description }, index}
    <div
        class="border-2 border-gray-300 p-4 rounded-lg flex-1 text-left text-base"
        class:bg-gray-900={selectedChoice === index}
        class:border-gray-500={selectedChoice !== index}
        class:bg-gray-700={selectedChoice !== index}
    >
        <div>
            {@html description}
            <div class="flex items-center justify-center gap-2">
                {#each teamChoices as teamChoice}
                    {#if teamChoice.option === index && teamChoice.team}
                        <TeamLogo
                            team={teamChoice.team}
                            size="sm"
                            border={false}
                        />
                    {/if}
                {/each}
            </div>
        </div>
    </div>
{/each}
<Accordion border={false} flush={true}>
    <AccordionItem
        paddingFlush=""
        defaultClass="flex items-center font-medium w-full text-right justify-center gap-2"
    >
        <span slot="header">
            <div class="text-md text-right">Outcomes</div>
        </span>
        <span slot="arrowdown">
            <ChevronDoubleDownOutline size="xs" />
        </span>
        <div slot="arrowup">
            <ChevronDoubleUpOutline size="xs" />
        </div>

        {#each state.effectOutcomes as outcome}
            <div>{getOutcomeText(outcome)}</div>
        {/each}
    </AccordionItem>
</Accordion>
