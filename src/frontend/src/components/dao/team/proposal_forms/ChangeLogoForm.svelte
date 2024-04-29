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
    <div class="p-2">Updates the logo of the team.</div>
    <div class="p-2">Requires a league approval vote.</div>
    <Label>Logo Url</Label>
    <Input type="url" bind:value={logoUrl} />
</FormTemplate>
