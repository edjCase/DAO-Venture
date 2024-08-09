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
    import { townStore } from "../stores/TownStore";
    import { Principal } from "@dfinity/principal";
    import MemberList from "./dao/MemberList.svelte";
    import { mainAgentFactory } from "../ic-agent/Main";
    import { userStore } from "../stores/UserStore";
    $: towns = $townStore;

    let townItems: SelectOptionType<bigint>[] | undefined;
    let selectedTownId: bigint | undefined;
    let newMemberId: string = "";

    $: {
        if (towns && towns.length > 0) {
            townItems = towns.map((town) => {
                return {
                    value: town.id,
                    name: town.name,
                };
            });
            if (!selectedTownId) {
                selectedTownId = townItems[0].value;
            }
        }
    }

    let assignMember = async () => {
        if (selectedTownId === undefined) {
            console.log("No town selected");
            return;
        }
        console.log("Assigning member to town", newMemberId, selectedTownId);
        let userId = Principal.fromText(newMemberId);
        let mainAgent = await mainAgentFactory();
        let res = await mainAgent.assignUserToTown({
            townId: BigInt(selectedTownId),
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

{#if townItems}
    <div class="text-3xl">Town DAO Admin Panel</div>
    <hr class="mb-6" />
    <div class="text-2xl">Town Context:</div>
    <Select items={townItems} bind:value={selectedTownId} />

    {#if selectedTownId !== undefined}
        <Tabs>
            <TabItem title="Members" open>
                <MemberList townId={selectedTownId} />
                <div class="text-2xl">Assign User to Town</div>
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
