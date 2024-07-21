<script lang="ts">
    import TownProposalForm from "../dao/town/TownProposalForm.svelte";
    import TownProposalList from "../dao/town/TownProposalList.svelte";
    import TownFlag from "../town/TownFlag.svelte";
    import { townStore } from "../../stores/TownStore";
    import { userStore } from "../../stores/UserStore";
    import { Badge, TabItem, Tabs } from "flowbite-svelte";
    import SectionWithOverview from "../common/SectionWithOverview.svelte";
    import { ChervonDoubleUpSolid } from "flowbite-svelte-icons";
    import LoadingButton from "../common/LoadingButton.svelte";
    import { mainAgentFactory } from "../../ic-agent/Main";

    $: towns = $townStore;

    $: user = $userStore;

    $: town = towns?.find((t) => t.id == user?.residency[0]?.townId);
    $: votingPower = user?.residency[0]?.votingPower || 0;
    let join = async () => {
        let mainAgent = await mainAgentFactory();
        let result = await mainAgent.joinWorld();
        if ("ok" in result) {
            console.log("Joined world", result);
            userStore.refetchCurrentUser();
            userStore.refetchStats();
        } else {
            console.log("Error joining world", result);
        }
    };
</script>

{#if town}
    <SectionWithOverview title={town.name}>
        <TownFlag slot="title-img" {town} size="md" />
        <div class="flex w-full mb-4 text-center">
            <div class="flex-grow">
                <div class="text-xl">Town</div>
                <div>{town.currency} 💰</div>
                <div>{town.entropy} 🔥</div>
            </div>
            <div class="flex-grow">
                <div class="text-xl">You</div>
                <div>
                    Level:
                    {#if votingPower <= 0}
                        <span class="text-green-500 bold">FAN</span>
                        <a
                            href="https://oc.app/community/cghnf-2qaaa-aaaar-baa6a-cai/channel/61170281920579717573386498610085170743"
                            target="_blank"
                        >
                            <Badge
                                rounded
                                large
                                title="Upgrade to Co-Owner"
                                color="primary"
                                class="ml-2 p-1 cursor-pointer"
                            >
                                <ChervonDoubleUpSolid size="xs" />
                                <span class="sr-only">Upgrade</span>
                            </Badge>
                        </a>
                    {:else}
                        <span class="text-blue-500 bold"> CO-OWNER </span>
                    {/if}
                </div>
                {#if votingPower > 0}
                    <div>Voting Power: {votingPower}</div>
                {/if}
            </div>
        </div>
        <Tabs
            defaultClass="flex space-x-1 overflow-y-auto"
            inactiveClasses="p-4 rounded-t-lg text-gray-400 bg-gray-900 hover:bg-gray-700 hover:text-gray-300"
            activeClasses="p-4 rounded-t-lg bg-gray-700 text-primary-500"
            contentClass="p-4 rounded-b-lg bg-gray-800 border-2 border-gray-700"
        >
            <TabItem title="Proposals" open>
                <div class="mt-5">
                    <TownProposalList townId={town.id} />
                </div>
                {#if votingPower > 0}
                    <div class="mt-5">
                        <TownProposalForm townId={town.id} />
                    </div>
                {/if}
            </TabItem>
        </Tabs>
    </SectionWithOverview>
{:else}
    <div>
        Want to join in and participate in world governance? Join the world and
        get assigned to a random town!
    </div>
    <LoadingButton onClick={join}>Join</LoadingButton>
{/if}
