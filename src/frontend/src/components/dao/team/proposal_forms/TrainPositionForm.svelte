<script lang="ts">
    import { Select } from "flowbite-svelte";
    import {
        FieldPosition,
        Skill,
    } from "../../../../ic-agent/declarations/players";
    import FormTemplate from "./FormTemplate.svelte";
    import { ProposalContent } from "../../../../ic-agent/declarations/teams";

    export let teamId: bigint;
    let skillTypes = [
        {
            value: "speed",
            name: "Speed",
        },
        {
            value: "battingAccuracy",
            name: "Batting Accuracy",
        },
        {
            value: "battingPower",
            name: "Batting Power",
        },
        {
            value: "catching",
            name: "Catching",
        },
        {
            value: "defense",
            name: "Defense",
        },
        {
            value: "throwingAccuracy",
            name: "Throwing Accuracy",
        },
        {
            value: "throwingPower",
            name: "Throwing Power",
        },
    ];
    let positions = [
        {
            value: "pitcher",
            name: "Pitcher",
        },
        {
            value: "firstBase",
            name: "First Base",
        },
        {
            value: "secondBase",
            name: "Second Base",
        },
        {
            value: "thirdBase",
            name: "Third Base",
        },
        {
            value: "shortStop",
            name: "Short Stop",
        },
        {
            value: "leftField",
            name: "Left Field",
        },
        {
            value: "centerField",
            name: "Center Field",
        },
        {
            value: "rightField",
            name: "Right Field",
        },
    ];
    let selectedSkillId = skillTypes[0].value;
    let selectedPosition: string = "pitcher";

    let generateProposal = (): ProposalContent | string => {
        if (selectedPosition === undefined) {
            return "No position selected";
        }

        let position: FieldPosition;
        // TODO auto-generate this?
        switch (selectedPosition) {
            case "pitcher":
                position = { pitcher: null };
                break;
            case "firstBase":
                position = { firstBase: null };
                break;
            case "secondBase":
                position = { secondBase: null };
                break;
            case "thirdBase":
                position = { thirdBase: null };
                break;
            case "shortStop":
                position = { shortStop: null };
                break;
            case "leftField":
                position = { leftField: null };
                break;
            case "centerField":
                position = { centerField: null };
                break;
            case "rightField":
                position = { rightField: null };
                break;
            default:
                throw new Error("Unknown position: " + selectedPosition);
        }
        let skill: Skill;
        // TODO auto-generate this?
        switch (selectedSkillId) {
            case "speed":
                skill = { speed: null };
                break;
            case "battingAccuracy":
                skill = { battingAccuracy: null };
                break;
            case "battingPower":
                skill = { battingPower: null };
                break;
            case "catching":
                skill = { catching: null };
                break;
            case "defense":
                skill = { defense: null };
                break;
            case "throwingAccuracy":
                skill = { throwingAccuracy: null };
                break;
            case "throwingPower":
                skill = { throwingPower: null };
                break;
            default:
                throw new Error("Unknown skill type: " + selectedSkillId);
        }
        return {
            train: {
                position: position,
                skill: skill,
            },
        };
    };
</script>

<FormTemplate {generateProposal} {teamId}>
    <Select items={skillTypes} bind:value={selectedSkillId} />
    <Select items={positions} bind:value={selectedPosition} />
</FormTemplate>
