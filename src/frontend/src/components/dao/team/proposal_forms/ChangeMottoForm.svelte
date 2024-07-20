<script lang="ts">
    import { Input, Label } from "flowbite-svelte";
    import { ProposalContent } from "../../../../ic-agent/declarations/main";
    import FormTemplate from "./FormTemplate.svelte";

    export let townId: bigint;

    let motto: string | undefined;

    let generateProposal = (): ProposalContent | string => {
        if (motto === undefined) {
            return "No motto provided";
        }
        return {
            changeMotto: {
                motto: motto,
            },
        };
    };
</script>

<FormTemplate {generateProposal} {townId}>
    <div class="p-2">Updates the motto of the town.</div>
    <div class="p-2">Requires a world approval vote.</div>
    <Label>Motto</Label>
    <Input type="text" bind:value={motto} />
</FormTemplate>
