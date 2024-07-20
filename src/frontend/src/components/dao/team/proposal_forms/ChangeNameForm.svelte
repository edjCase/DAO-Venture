<script lang="ts">
    import { Input, Label } from "flowbite-svelte";
    import FormTemplate from "./FormTemplate.svelte";
    import { ProposalContent } from "../../../../ic-agent/declarations/main";

    export let townId: bigint;
    let newName: string | undefined;

    let generateProposal = (): ProposalContent | string => {
        if (newName === undefined) {
            return "No new name selected";
        }
        return {
            changeName: {
                name: newName,
            },
        };
    };
</script>

<FormTemplate {generateProposal} {townId}>
    <div class="p-2">Updates the name of the town.</div>
    <div class="p-2">Requires a league approval vote.</div>
    <Label>Name</Label>
    <Input type="text" bind:value={newName} />
</FormTemplate>
