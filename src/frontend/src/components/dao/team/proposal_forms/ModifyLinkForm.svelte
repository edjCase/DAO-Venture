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
    <div class="p-2">Creates a new link for the team page</div>
    <div class="p-2">
        Specifying a name of an existing link, it will update the link. If the
        link has no url specified, it will be deleted
    </div>
    <Label>Name</Label>
    <Input type="text" bind:value={name} />
    <Label>Url</Label>
    <Input type="url" bind:value={url} />
</FormTemplate>
