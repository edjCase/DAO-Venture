<script lang="ts">
    import { Job } from "../../../../ic-agent/declarations/main";
    import AddUpdateJobForm from "./AddUpdateJobForm.svelte";

    export let townId: bigint;
    let job: Job = {
        explore: {
            locationId: 0n,
        },
    };
</script>

<AddUpdateJobForm {job} jobId={undefined} {townId} />
