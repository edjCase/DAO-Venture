<script lang="ts">
    import { Label, Select } from "flowbite-svelte";
    import { ProposalContent } from "../../../../ic-agent/declarations/main";
    import FormTemplate from "./FormTemplate.svelte";
    import {
        FieldPositionEnum,
        fromEnum,
    } from "../../../../models/FieldPosition";

    export let townId: bigint;

    let positions = Object.entries(FieldPositionEnum).map(([_, enumValue]) => {
        return {
            name: enumValue.toString(),
            value: enumValue.toString(),
        };
    });
    let position1: FieldPositionEnum = FieldPositionEnum.Pitcher;
    let position2: FieldPositionEnum = FieldPositionEnum.FirstBase;

    let generateProposal = (): ProposalContent | string => {
        if (position1 === undefined) {
            return "Position 1 not provided";
        }
        if (position2 === undefined) {
            return "Position 2 not provided";
        }
        if (position1 === position2) {
            return "Positions are the same";
        }
        return {
            swapPlayerPositions: {
                position1: fromEnum(position1),
                position2: fromEnum(position2),
            },
        };
    };
</script>

<FormTemplate {generateProposal} {townId}>
    <div class="p-2">Swaps the position of two players</div>
    <Label>Position 1</Label>
    <Select items={positions} bind:value={position1} />
    <Label>Position 2</Label>
    <Select items={positions} bind:value={position2} />
</FormTemplate>
