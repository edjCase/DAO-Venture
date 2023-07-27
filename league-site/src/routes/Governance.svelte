<script lang="ts">
  import { Link } from "svelte-routing";
  import { proposalStore } from "../stores/ProposalStore";
  import type { Proposal } from "../types/Governance";

  let pendingProposals: Proposal[] = $proposalStore.filter(
    (item) => item.status == "pending"
  );
  let adoptedProposals: Proposal[] = $proposalStore.filter(
    (item) => item.status == "adopted"
  );
</script>

<div class="governance-container">
  <div class="proposals">
    <h1>Pending</h1>
    {#each pendingProposals as proposal}
      <Link to={`/proposals/${proposal.id}`}>
        <div class="proposal">
          <h2>{proposal.title}</h2>
        </div>
      </Link>
    {/each}
  </div>
  <div class="proposals">
    <h1>Adopted</h1>
    {#each adoptedProposals as proposal}
      <Link to={`/proposals/${proposal.id}`}>
        <div class="proposal">
          <h2>{proposal.title}</h2>
        </div>
      </Link>
    {/each}
  </div>
</div>

<style>
  .governance-container {
    display: flex;
    justify-content: space-around;
  }
  .proposals {
    min-width: 40%;
  }
  .proposal {
    padding: 10px;
    border: 1px solid var(--color-secondary);
    cursor: pointer;
  }
  .proposal h2 {
    text-decoration: none;
  }
</style>
