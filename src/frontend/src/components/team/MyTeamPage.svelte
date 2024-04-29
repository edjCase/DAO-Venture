<script lang="ts">
    import TeamProposalForm from "../dao/team/TeamProposalForm.svelte";
    import TeamProposalList from "../dao/team/TeamProposalList.svelte";
    import TeamLogo from "../team/TeamLogo.svelte";
    import { User } from "../../ic-agent/declarations/users";
    import { identityStore } from "../../stores/IdentityStore";
    import { teamStore } from "../../stores/TeamStore";
    import { userStore } from "../../stores/UserStore";
    import { Badge, Button, TabItem, Tabs } from "flowbite-svelte";
    import MatchHistory from "../match/MatchHistory.svelte";
    import TeamGrid from "./TeamGrid.svelte";
    import PlayerRoster from "../player/PlayerRoster.svelte";
    import SectionWithOverview from "../common/SectionWithOverview.svelte";
    import { ChervonDoubleUpSolid } from "flowbite-svelte-icons";
    import { TeamStandingInfo } from "../../ic-agent/declarations/league";

    $: identity = $identityStore;
    $: teams = $teamStore;

    let user: User | undefined;
    let standings: TeamStandingInfo[] | undefined;

    $: {
        if (identity.getPrincipal().isAnonymous()) {
            user = undefined;
        } else {
            userStore.subscribeUser(identity.getPrincipal(), (u) => {
                user = u;
            });
        }
    }
    teamStore.subscribeTeamStandings((s) => {
        standings = s;
    });
    $: links = teams?.find((l) => l.id == user?.team[0]?.id)?.links || [];
    $: team = teams?.find((t) => t.id == user?.team[0]?.id);
    $: votingPower =
        user?.team[0]?.kind && "owner" in user.team[0].kind
            ? user.team[0].kind.owner.votingPower
            : 0;
    $: standing = standings?.find((s) => s.id == team?.id) || {
        wins: 0,
        losses: 0,
    };
</script>

{#if team}
    <SectionWithOverview title={team.name}>
        <TeamLogo slot="title-img" {team} size="md" />
        <div class="flex w-full mb-4 text-center">
            <div class="flex-grow">
                <div class="text-xl">Team</div>
                <div>Energy: {team.energy}</div>
                <div>Entropy: {team.entropy}</div>
                <div>Wins: {standing?.wins}</div>
                <div>Losses: {standing?.losses}</div>
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
                    <TeamProposalList teamId={team.id} />
                </div>
                {#if votingPower > 0}
                    <div class="mt-5">
                        <TeamProposalForm teamId={team.id} />
                    </div>
                {/if}
            </TabItem>
            <TabItem title="Match History">
                <MatchHistory teamId={team.id} />
            </TabItem>
            <TabItem title="Roster">
                <PlayerRoster teamId={team.id} />
            </TabItem>
            <TabItem title="Links">
                {#if links.length == 0}
                    <div class="text-center">No links</div>
                {:else}
                    <div class="flex justify-around">
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
    <SectionWithOverview title="Pick a Team">
        <TeamGrid />
    </SectionWithOverview>
{/if}
