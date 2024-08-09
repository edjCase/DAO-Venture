<script lang="ts">
    import { Principal } from "@dfinity/principal";
    import { mainAgentFactory } from "../../ic-agent/Main";
    import { MultiSelect } from "flowbite-svelte";
    import { buildUserPseudonym } from "./UserPseudonym.svelte";

    export let townId: bigint;
    export let value: Principal[];

    let townUsers: { name: string; value: string }[] | undefined;

    let refreshUsers = async (townId: bigint) => {
        let mainAgent = await mainAgentFactory();
        let result = await mainAgent.getUsers({ town: townId });
        if ("ok" in result) {
            townUsers = result.ok.map((user) => ({
                name: buildUserPseudonym(user.id),
                value: user.id.toString(),
            }));
        } else {
            console.error("Failed to get town owners: ", result);
            townUsers = undefined;
        }
    };
    $: refreshUsers(townId);

    let userIds = value.map((id) => id.toString());

    $: value = userIds.map((id) => Principal.fromText(id));
</script>

<MultiSelect items={townUsers} bind:value={userIds} />
