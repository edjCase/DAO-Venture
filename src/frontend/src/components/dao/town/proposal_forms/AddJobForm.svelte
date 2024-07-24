<script lang="ts">
    import { Input, Label } from "flowbite-svelte";
    import FormTemplate from "./FormTemplate.svelte";
    import {
        Job,
        TownProposalContent,
    } from "../../../../ic-agent/declarations/main";

    export let townId: bigint;
    let newJob: Job | undefined;

    let generateProposal = (): TownProposalContent | string => {
        if (newJob === undefined) {
            return "No new name selected";
        }
        return {
            addJob: {
                job: newJob,
            },
        };
    };
</script>

<FormTemplate {generateProposal} {townId}>
    <div class="p-2">Updates the name of the town.</div>
    <div class="p-2">Requires a world approval vote.</div>
    <Label>Name</Label>
    <Input type="text" bind:value={newName} />
</FormTemplate>
