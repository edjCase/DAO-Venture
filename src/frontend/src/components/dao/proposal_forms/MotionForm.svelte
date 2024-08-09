<script lang="ts">
    import { Input, Label, Textarea } from "flowbite-svelte";
    import FormTemplate from "./FormTemplate.svelte";
    import { CreateWorldProposalRequest } from "../../../ic-agent/declarations/main";

    let title: string | undefined;
    let description: string | undefined;

    let generateProposal = (): CreateWorldProposalRequest | string => {
        if (description === undefined) {
            return "No motto provided";
        }
        if (title === undefined) {
            return "No title provided";
        }
        return {
            motion: {
                title: title,
                description: description,
            },
        };
    };
</script>

<FormTemplate {generateProposal}>
    <div class="p-2">
        Creates a motion proposal, with no executed effect if adopted
    </div>
    <Label>Title</Label>
    <Input type="text" bind:value={title} />
    <Label>Content</Label>
    <Textarea bind:value={description} />
</FormTemplate>
