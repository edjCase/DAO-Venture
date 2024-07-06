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
        let mainAgent = await mainAgentFactory();
        let res = await mainAgent.addTeamOwner({
            teamId: BigInt(selectedTeamId),
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

{#if teamItems}
    <div class="text-3xl">Team DAO Admin Panel</div>
    <hr class="mb-6" />
    <div class="text-2xl">Team Context:</div>
    <Select items={teamItems} bind:value={selectedTeamId} />

    {#if selectedTeamId}
        <Tabs>
            <TabItem title="Members" open>
                <MemberList teamId={BigInt(selectedTeamId)} />
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
