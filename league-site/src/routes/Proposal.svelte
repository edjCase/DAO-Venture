<script lang="ts">
    import { proposalStore } from "../stores/ProposalStore";
    import type { Proposal } from "../types/Governance";

    export let id;

    let proposal: Proposal = $proposalStore.find((item) => item.id == id);
</script>

<section>
    <h1>{proposal.title}</h1>
    <p><strong>ID:</strong> {proposal.id}</p>
    <!-- <p><strong>Type:</strong> {proposal.type}</p> -->
    <p><strong>Description:</strong> {proposal.description}</p>
    <!-- <p><strong>Submitter:</strong> {proposal.proposer}</p>
    <p><strong>Timestamp:</strong> {proposal.date}</p> -->
    <p><strong>Status:</strong> {proposal.status}</p>
</section>
