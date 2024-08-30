<script lang="ts">
  import { TabItem, Tabs } from "flowbite-svelte";
  import ProposalList from "./ProposalList.svelte";
  import ProposalForm from "./ProposalForm.svelte";
  import { userStore } from "../../stores/UserStore";
  import LoadingValue from "../common/LoadingValue.svelte";
  import { UserStats } from "../../ic-agent/declarations/main";

  let userStats: UserStats | undefined;

  userStore.subscribeStats((stats) => {
    userStats = stats;
  });

  $: user = $userStore;
</script>

<div class="text-3xl text-center my-5">World</div>
<div class="text-center">
  <div class="flex items-center justify-center">
    <span class="mr-2">Users:</span>
    <LoadingValue value={userStats?.userCount} />
  </div>
</div>
<Tabs>
  <TabItem title="Proposals" open>
    <ProposalList />
    {#if user !== undefined}
      <ProposalForm />
    {/if}
  </TabItem>
</Tabs>
