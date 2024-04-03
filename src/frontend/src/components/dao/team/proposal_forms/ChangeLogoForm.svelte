<script lang="ts">
    import { Input, Label } from "flowbite-svelte";
    import { ProposalContent } from "../../../../ic-agent/declarations/teams";
    import FormTemplate from "./FormTemplate.svelte";

    export let teamId: bigint;

    let logoUrl: string | undefined;

    let generateProposal = (): ProposalContent | string => {
        if (logoUrl === undefined) {
            return "No logo url provided";
        }
        return {
            changeLogo: {
                logoUrl: logoUrl,
            },
        };
    };
</script>

<FormTemplate {generateProposal} {teamId}>
    <Label>Logo Url</Label>
    <Input type="url" bind:value={logoUrl} />
</FormTemplate>
