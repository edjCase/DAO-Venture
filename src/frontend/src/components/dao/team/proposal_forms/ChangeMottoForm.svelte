<script lang="ts">
    import { Input, Label } from "flowbite-svelte";
    import { ProposalContent } from "../../../../ic-agent/declarations/teams";
    import FormTemplate from "./FormTemplate.svelte";

    export let teamId: bigint;

    let motto: string | undefined;

    let generateProposal = (): ProposalContent | string => {
        if (motto === undefined) {
            return "No motto provided";
        }
        return {
            changeLogo: {
                logoUrl: motto,
            },
        };
    };
</script>

<FormTemplate {generateProposal} {teamId}>
    <Label>Motto</Label>
    <Input type="text" bind:value={motto} />
</FormTemplate>
