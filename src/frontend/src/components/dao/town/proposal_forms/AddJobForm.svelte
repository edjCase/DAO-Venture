<script lang="ts">
    import { Job } from "../../../../ic-agent/declarations/main";
    import AddUpdateJobForm from "./AddUpdateJobForm.svelte";

    export let townId: bigint;
    let job: Job = {
        gatherResource: {
            locationId: 0n,
            resource: { wood: null },
            workerQuota: 100n,
        },
    };
</script>

<AddUpdateJobForm {job} jobId={undefined} {townId} />
