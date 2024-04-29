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
    <div class="p-2">Updates the description of the team.</div>
    <div class="p-2">Requires a league approval vote.</div>
    <Label>Description</Label>
    <Input type="text" bind:value={description} />
</FormTemplate>
