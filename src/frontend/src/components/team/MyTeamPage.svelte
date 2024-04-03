<script lang="ts">
    import TeamProposalForm from "../dao/team/TeamProposalForm.svelte";
    import TeamProposalList from "../dao/team/TeamProposalList.svelte";
    import TeamLogo from "../team/TeamLogo.svelte";
    import { User } from "../../ic-agent/declarations/users";
    import { identityStore } from "../../stores/IdentityStore";
    import { teamStore } from "../../stores/TeamStore";
    import { userStore } from "../../stores/UserStore";
    import { Button, TabItem, Tabs } from "flowbite-svelte";
    import MatchHistory from "../match/MatchHistory.svelte";
    import TeamStats from "./TeamStats.svelte";
    import TeamGrid from "./TeamGrid.svelte";
    import PlayerRoster from "../player/PlayerRoster.svelte";

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

<div class="p-2 border rounded mt-2">
    {#if team}
        <div class="flex-1 flex justify-center items-center gap-2">
            <TeamLogo {team} size="md" />
            <div class="text-3xl">{team.name}</div>
        </div>
        <div class="p-2">
            {#if votingPower <= 0}
                <div>
                    You are just a FAN. Become a Coowner <Button>HERE</Button> to
                    be able to create and vote on proposals.
                </div>
            {:else}
                <div class="text-center">Voting Power: {votingPower}</div>
            {/if}
        </div>
        <Tabs>
            <TabItem title="Summary" open>
                <TeamStats teamId={team.id} />
                <MatchHistory teamId={team.id} />
            </TabItem>
            <TabItem title="Roster">
                <PlayerRoster teamId={team.id} />
            </TabItem>
            <TabItem title="Proposals">
                <div class="mt-5">
                    <TeamProposalList teamId={team.id} />
                </div>
                {#if votingPower > 0}
                    <div class="mt-5">
                        <TeamProposalForm teamId={team.id} />
                    </div>
                {/if}
            </TabItem>
        </Tabs>
    {:else}
        <div>You are not a member of any team, choose a team to follow:</div>

        <TeamGrid />
    {/if}
</div>
