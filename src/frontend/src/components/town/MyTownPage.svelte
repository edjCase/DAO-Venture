<script lang="ts">
    import TownProposalForm from "../dao/town/TownProposalForm.svelte";
    import TownProposalList from "../dao/town/TownProposalList.svelte";
    import TownFlag from "../town/TownFlag.svelte";
    import { townStore } from "../../stores/TownStore";
    import { userStore } from "../../stores/UserStore";
    import { Button, TabItem, Tabs } from "flowbite-svelte";
    import SectionWithOverview from "../common/SectionWithOverview.svelte";
    import ResourceIcon from "../icons/ResourceIcon.svelte";
    import { nanosecondsToDate } from "../../utils/DateUtils";
    import TownJobs from "./TownJobs.svelte";
    import { Link } from "svelte-routing";

    $: towns = $townStore;

    $: user = $userStore;

    $: town = towns?.find((t) => t.id == user?.worldData?.townId);

    function getTimeAgo(nanoseconds: bigint): string {
        const date = nanosecondsToDate(nanoseconds);
        const now = new Date();
        const diffInMilliseconds = now.getTime() - date.getTime();
        const diffInDays = Math.floor(
            diffInMilliseconds / (1000 * 60 * 60 * 24),
        );

        return `${diffInDays} days ago`;
    }
</script>

{#if town}
    <SectionWithOverview title={town.name}>
        <TownFlag slot="title-img" {town} size="md" />
        <div class="flex w-full mb-4 text-center">
            <div class="flex-grow">
                <div class="text-xl">Town</div>
                <div>
                    {town.resources.gold}
                    <ResourceIcon kind={{ gold: null }} />
                </div>
                <div>
                    {town.resources.food}
                    <ResourceIcon kind={{ food: null }} />
                </div>
                <div>
                    {town.resources.wood}
                    <ResourceIcon kind={{ wood: null }} />
                </div>
                <div>
                    {town.resources.stone}
                    <ResourceIcon kind={{ stone: null }} />
                </div>
            </div>
            <div class="flex-grow">
                {#if user?.worldData !== undefined}
                    <div class="text-xl">You</div>
                    <div>
                        Level: {user.worldData.level}
                    </div>
                    <div>
                        Joined Town: {getTimeAgo(user.worldData.atTownSince)}
                    </div>
                    <div>
                        Joined World: {getTimeAgo(user.worldData.inWorldSince)}
                    </div>
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
                <div class="mt-5">
                    <TownProposalForm townId={town.id} />
                </div>
            </TabItem>
            <TabItem title="Jobs">
                <div class="mt-5">
                    <TownJobs townId={town.id} />
                </div>
            </TabItem>
        </Tabs>
    </SectionWithOverview>
{:else}
    <div>
        Want to join in and participate in world governance? Pick a town on the
        grid and join up!
    </div>
    <Link to="/"><Button>Home</Button></Link>
{/if}
