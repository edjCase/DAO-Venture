<script lang="ts">
    import TeamCreateProposal from "../dao/TeamCreateProposal.svelte";
    import TeamProposalList from "../dao/TeamProposalList.svelte";
    import TeamLogo from "../team/TeamLogo.svelte";
    import { User } from "../../ic-agent/declarations/users";
    import { identityStore } from "../../stores/IdentityStore";
    import { teamStore } from "../../stores/TeamStore";
    import { userStore } from "../../stores/UserStore";
    import { Button, TabItem, Tabs } from "flowbite-svelte";
    import MatchHistory from "../match/MatchHistory.svelte";
    import TeamStats from "./TeamStats.svelte";
    import TeamGrid from "./TeamGrid.svelte";

    $: identity = $identityStore;
    $: teams = $teamStore;

    let user: User | undefined;

    $: {
        if (identity.getPrincipal().isAnonymous()) {
            user = undefined;
        } else {
            userStore.subscribeUser(identity.getPrincipal(), (u) => {
                user = u;
            });
        }
    }
    $: team = teams?.find((t) => t.id == user?.team[0]?.id);
    $: votingPower =
        user?.team[0]?.kind && "owner" in user.team[0].kind
            ? user.team[0].kind.owner.votingPower
            : 0;
</script>

{#if team}
    <div class="p-5">
        <TeamLogo {team} size="md" />
        <div class="text-5xl text-center mb-2">{team.name}</div>
    </div>
    {#if votingPower <= 0}
        <div>
            You are just a FAN. Become a Coowner <Button>HERE</Button> to be able
            to create and vote on proposals.
        </div>
    {:else}
        Voting Power: {votingPower}
    {/if}
    <Tabs>
        <TabItem title="Summary" open>
            <TeamStats teamId={team.id} />
            <MatchHistory teamId={team.id} />
        </TabItem>
        <TabItem title="Proposals">
            <div class="mt-5">
                <TeamProposalList teamId={team.id} />
            </div>
            {#if votingPower > 0}
                <div class="mt-5">
                    <TeamCreateProposal teamId={team.id} />
                </div>
            {/if}
        </TabItem>
    </Tabs>
{:else}
    <div>You are not a member of any team, choose a team to follow:</div>

    <TeamGrid />
{/if}
