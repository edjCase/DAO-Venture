<script lang="ts">
    import FormTemplate from "./FormTemplate.svelte";
    import { TownProposalContent } from "../../../../ic-agent/declarations/main";
    import JobSelector from "./JobSelector.svelte";

    export let townId: bigint;
    let jobId: bigint = 0n;

    let generateProposal = (): TownProposalContent | string => {
        return {
            removeJob: {
                jobId: jobId,
            },
        };
    };

    let onJobSelect = () => {};
</script>

<FormTemplate {generateProposal} {townId}>
    <JobSelector {townId} bind:value={jobId} {onJobSelect} />
</FormTemplate>
