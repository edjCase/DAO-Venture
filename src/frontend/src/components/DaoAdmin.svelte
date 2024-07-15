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
    import MemberList from "./dao/MemberList.svelte";
    import { mainAgentFactory } from "../ic-agent/Main";
    import { userStore } from "../stores/UserStore";
    $: teams = $teamStore;

    let teamItems: SelectOptionType<bigint>[] | undefined;
    let selectedTeamId: bigint | undefined;
    let newMemberId: string = "";

    $: {
        if (teams && teams.length > 0) {
            teamItems = teams.map((team) => {
                return {
                    value: team.id,
                    name: team.name,
                };
            });
            if (!selectedTeamId) {
                selectedTeamId = teamItems[0].value;
            }
        }
    }

    let assignMember = async () => {
        if (!selectedTeamId) {
            console.log("No team selected");
            return;
        }
        console.log("Assigning member to team", newMemberId, selectedTeamId);
        let userId = Principal.fromText(newMemberId);
        let mainAgent = await mainAgentFactory();
        let res = await mainAgent.assignUserToTeam({
            teamId: BigInt(selectedTeamId),
            userId: userId,
        });

        if ("ok" in res) {
            console.log("Assigning member", res);
            userStore.refetchCurrentUser();
        } else {
            console.log("Error assigning member", res);
        }
    };
</script>

{#if teamItems}
    <div class="text-3xl">Team DAO Admin Panel</div>
    <hr class="mb-6" />
    <div class="text-2xl">Team Context:</div>
    <Select items={teamItems} bind:value={selectedTeamId} />

    {#if selectedTeamId !== undefined}
        <Tabs>
            <TabItem title="Members" open>
                <MemberList teamId={selectedTeamId} />
                <div class="text-2xl">Assign User to Team</div>
                <div class="mb-6">
                    <Label for="default-input" class="block mb-2">User Id</Label
                    >
                    <Input id="default-input" bind:value={newMemberId} />
                    <Button on:click={assignMember}>Assign</Button>
                </div>
            </TabItem>
        </Tabs>
    {/if}
{/if}
