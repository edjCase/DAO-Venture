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

<Tabs>
  <TabItem title="Proposals" open>
    <ProposalList />
  </TabItem>
  <TabItem title="Create Proposal" disabled={user === undefined}>
    <ProposalForm />
  </TabItem>
  <TabItem title="DAO Info">
    <div class="flex items-center justify-center">
      <span class="mr-2">Users:</span>
      <LoadingValue value={userStats?.userCount} />
    </div>
  </TabItem>
</Tabs>
