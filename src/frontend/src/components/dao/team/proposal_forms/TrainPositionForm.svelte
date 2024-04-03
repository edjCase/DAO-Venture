<script lang="ts">
    import { Input, Select } from "flowbite-svelte";
    import LoadingButton from "../../../common/LoadingButton.svelte";
    import {
        FieldPosition,
        Skill,
    } from "../../../../ic-agent/declarations/players";
    import { teamsAgentFactory } from "../../../../ic-agent/Teams";
    import { proposalStore } from "../../../../stores/ProposalStore";

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
    let selectedSkillId = skillTypes[0].value;
    let selectedPosition: string | undefined;

    let createTrainPlayerProposal = async () => {
        if (selectedPosition === undefined) {
            console.log("No position selected");
            return;
        }
        console.log("Creating train player proposal");

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
        let teamsAgent = await teamsAgentFactory();

        let result = await teamsAgent.createProposal(teamId, {
            content: {
                train: {
                    position: position,
                    skill: skill,
                },
            },
        });
        console.log("Create Proposal Result: ", result);
        if ("ok" in result) {
            proposalStore.refetchTeamProposal(teamId, result.ok);
        } else {
            console.error("Error creating proposal: ", result);
        }
    };
</script>

<div>
    <Select items={skillTypes} bind:value={selectedSkillId} />
    <Input type="text" placeholder="Position" bind:value={selectedPosition} />
    <LoadingButton onClick={createTrainPlayerProposal}>
        Create Proposal
    </LoadingButton>
</div>
