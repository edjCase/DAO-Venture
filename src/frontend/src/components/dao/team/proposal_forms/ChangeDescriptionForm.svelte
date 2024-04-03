<script lang="ts">
    import { Input, Label } from "flowbite-svelte";
    import { ProposalContent } from "../../../../ic-agent/declarations/teams";
    import FormTemplate from "./FormTemplate.svelte";

    export let teamId: bigint;

    let description: string | undefined;

    let generateProposal = (): ProposalContent | string => {
        if (description === undefined) {
            return "No motto provided";
        }
        return {
            changeDescription: {
                description: description,
            },
        };
    };
</script>

<FormTemplate {generateProposal} {teamId}>
    <Label>Description</Label>
    <Input type="text" bind:value={description} />
</FormTemplate>
