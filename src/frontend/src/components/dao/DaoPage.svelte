<script lang="ts">
  import { TabItem, Tabs, Card } from "flowbite-svelte";
  import ProposalList from "./ProposalList.svelte";
  import ProposalForm from "./ProposalForm.svelte";
  import { userStore } from "../../stores/UserStore";
  import { UserStats } from "../../ic-agent/declarations/main";

  let userStats: UserStats | undefined;

  userStore.subscribeStats((stats) => {
    userStats = stats;
  });

  $: user = $userStore;

  $: metricCards = [
    {
      title: "Active Proposals",
      value: "?", // TODO
      icon: "M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-6 9l2 2 4-4",
    },
    {
      title: "Treasury",
      value: "? ICP", // TODO
      icon: "M4 7v10c0 2.21 3.582 4 8 4s8-1.79 8-4V7M4 7c0-2.21 3.582-4 8-4s8 1.79 8 4m0 5c0 2.21-3.582 4-8 4s-8-1.79-8-4",
    },
    {
      title: "DAO Members",
      value: userStats?.userCount, // TODO
      icon: "M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z",
    },
    {
      title: "Your Voting Power",
      value: 1, // TODO
      icon: "M3 6l3 1m0 0l-3 9a5.002 5.002 0 006.001 0M6 7l3 9M6 7l6-2m6 2l3-1m-3 1l-3 9a5.002 5.002 0 006.001 0M18 7l3 9m-3-9l-6-2m0-2v2m0 16V5m0 16H9m3 0h3",
    },
  ];
</script>

<div>
  <h1 class="text-5xl font-semibold text-primary-500 my-4 text-center">
    DAO Governance
  </h1>
  <div class="grid grid-cols-1 md:grid-cols-2 gap-2 mb-6 justify-items-center">
    {#each metricCards as card}
      <Card padding="none" class="w-full max-w-sm">
        <div class="flex items-center">
          <div
            class="inline-flex flex-shrink-0 justify-center items-center w-12 h-12 text-primary-500 mr-2"
          >
            <svg
              class="w-6 h-6"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
              xmlns="http://www.w3.org/2000/svg"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d={card.icon}
              ></path>
            </svg>
          </div>
          <div class="w-full">
            <div class="text-xl">{card.title}</div>
            <div class="font-bold text-2xl">{card.value}</div>
          </div>
        </div>
      </Card>
    {/each}
  </div>

  <Tabs>
    <TabItem title="Proposals" open>
      <ProposalList />
    </TabItem>
    <TabItem title="Create Proposal" disabled={user === undefined}>
      <ProposalForm />
    </TabItem>
  </Tabs>
</div>
