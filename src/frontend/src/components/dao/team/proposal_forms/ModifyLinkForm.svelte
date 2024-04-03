<script lang="ts">
    import { Input, Label } from "flowbite-svelte";
    import { ProposalContent } from "../../../../ic-agent/declarations/teams";
    import FormTemplate from "./FormTemplate.svelte";

    export let teamId: bigint;

    let name: string | undefined;
    let url: string | undefined;

    let generateProposal = (): ProposalContent | string => {
        if (name === undefined) {
            return "No name provided";
        }
        return {
            modifyLink: {
                name: name,
                url: !url || url.trim() === "" ? [] : [url],
            },
        };
    };
</script>

<FormTemplate {generateProposal} {teamId}>
    <Label>Link Name</Label>
    <Input type="text" bind:value={name} />
    <Label>Link Url</Label>
    <Input type="url" bind:value={url} />
</FormTemplate>
