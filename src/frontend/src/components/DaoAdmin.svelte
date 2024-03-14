<script lang="ts">
    import {
        Button,
        Input,
        Label,
        Select,
        SelectOptionType,
        TabItem,
        Tabs,
    } from "flowbite-svelte";
    import { teamStore } from "../stores/TeamStore";
    import { Principal } from "@dfinity/principal";
    import TeamCreateProposal from "./dao/TeamCreateProposal.svelte";
    import MemberList from "./dao/MemberList.svelte";
    import { usersAgentFactory } from "../ic-agent/Users";
    import { userStore } from "../stores/UserStore";
    import TeamProposalList from "./dao/TeamProposalList.svelte";
    import LeagueProposalList from "./dao/LeagueProposalList.svelte";

    $: teams = $teamStore;

    let teamItems: SelectOptionType<string>[] = [];
    let selectedTeamId: string | undefined;
    let newMemberId: string = "";

    $: {
        if (teams && teams.length > 0) {
            teamItems = teams.map((team) => {
                return {
                    value: team.id.toString(),
                    name: team.name,
                };
            });
            if (!selectedTeamId) {
                selectedTeamId = teamItems[0].value;
            }
        }
    }

    let addMember = async () => {
        if (!selectedTeamId) {
            console.log("No team selected");
            return;
        }
        console.log("Adding member", newMemberId);
        let userId = Principal.fromText(newMemberId);
        let res = await usersAgentFactory().addTeamOwner({
            teamId: Principal.fromText(selectedTeamId),
            userId: userId,
            votingPower: BigInt(1),
        });

        if ("ok" in res) {
            console.log("Added member", res);
            userStore.refetchUser(userId);
        } else {
            console.log("Error adding member", res);
        }
    };
</script>

<div class="text-3xl">League DAO Admin Panel</div>
<LeagueProposalList />

{#if teamItems}
    <div class="text-3xl">Team DAO Admin Panel</div>
    <hr class="mb-6" />
    <div class="text-2xl">Team Context:</div>
    <Select items={teamItems} bind:value={selectedTeamId} />

    {#if selectedTeamId}
        <Tabs>
            <TabItem open title="Proposals">
                <TeamProposalList teamId={selectedTeamId} />
                <TeamCreateProposal teamId={selectedTeamId} />
            </TabItem>
            <TabItem title="Members">
                <MemberList teamId={selectedTeamId} />
                <div class="text-2xl">Add a DAO member:</div>
                <div class="mb-6">
                    <Label for="default-input" class="block mb-2">User Id</Label
                    >
                    <Input id="default-input" bind:value={newMemberId} />
                    <Button on:click={addMember}>Add Member</Button>
                </div>
            </TabItem>
        </Tabs>
    {/if}
{/if}
