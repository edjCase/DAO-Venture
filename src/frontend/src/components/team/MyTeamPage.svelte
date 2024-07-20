<script lang="ts">
    import TownProposalForm from "../dao/town/TownProposalForm.svelte";
    import TownProposalList from "../dao/town/TownProposalList.svelte";
    import TownLogo from "../town/TownLogo.svelte";
    import { townStore } from "../../stores/TownStore";
    import { userStore } from "../../stores/UserStore";
    import { Badge, Button, TabItem, Tabs } from "flowbite-svelte";
    import MatchHistory from "../match/MatchHistory.svelte";
    import PlayerRoster from "../player/PlayerRoster.svelte";
    import SectionWithOverview from "../common/SectionWithOverview.svelte";
    import { ChervonDoubleUpSolid } from "flowbite-svelte-icons";
    import { TownStandingInfo } from "../../ic-agent/declarations/main";
    import LoadingButton from "../common/LoadingButton.svelte";
    import { mainAgentFactory } from "../../ic-agent/Main";

    $: towns = $townStore;

    let standings: TownStandingInfo[] | undefined;

    $: user = $userStore;

    $: links =
        towns?.find((l) => l.id == user?.membership[0]?.townId)?.links || [];
    $: town = towns?.find((t) => t.id == user?.membership[0]?.townId);
    $: votingPower = user?.membership[0]?.votingPower || 0;
    $: standing = standings?.find((s) => s.id == town?.id) || {
        wins: 0,
        losses: 0,
    };
    let join = async () => {
        let mainAgent = await mainAgentFactory();
        let result = await mainAgent.joinLeague();
        if ("ok" in result) {
            console.log("Joined league", result);
            userStore.refetchCurrentUser();
            userStore.refetchStats();
        } else {
            console.log("Error joining league", result);
        }
    };
</script>

{#if town}
    <SectionWithOverview title={town.name}>
        <TownLogo slot="title-img" {town} size="md" />
        <div class="flex w-full mb-4 text-center">
            <div class="flex-grow">
                <div class="text-xl">Town</div>
                <div>{town.currency} 💰</div>
                <div>{town.entropy} 🔥</div>
                <div>Wins: {standing?.wins}</div>
                <div>Losses: {standing?.losses}</div>
                {#each town.traits as trait}
                    <Badge>{trait.name}</Badge>
                {/each}
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
            <TabItem title="Matches">
                <MatchHistory townId={town.id} />
            </TabItem>
            <TabItem title="Roster">
                <PlayerRoster townId={town.id} />
            </TabItem>
            <TabItem title="Links">
                {#if links.length == 0}
                    <div class="text-center">No links</div>
                {:else}
                    <div class="flex flex-col gap-2">
                        {#each links as link}
                            <Button
                                href={link.url}
                                target="_blank"
                                rel="noopener noreferrer"
                            >
                                {link.name}
                            </Button>
                        {/each}
                    </div>
                {/if}
            </TabItem>
        </Tabs>
    </SectionWithOverview>
{:else}
    <div>
        Want to join in and participate in league governance? Join the league
        and get assigned to a random town!
    </div>
    <LoadingButton onClick={join}>Join</LoadingButton>
{/if}
