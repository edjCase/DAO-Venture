<script lang="ts">
    import { Input } from "flowbite-svelte";
    import FormTemplate from "./FormTemplate.svelte";
    import { ProposalContent } from "../../../../ic-agent/declarations/teams";

    export let teamId: bigint;
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

<FormTemplate {generateProposal} {teamId}>
    <Input type="text" placeholder="New Name" bind:value={newName} />
</FormTemplate>
