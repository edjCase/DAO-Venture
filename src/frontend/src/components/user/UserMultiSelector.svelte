<script lang="ts">
    import { Principal } from "@dfinity/principal";
    import { mainAgentFactory } from "../../ic-agent/Main";
    import { MultiSelect } from "flowbite-svelte";
    import { buildUserPseudonym } from "./UserPseudonym.svelte";

    export let value: Principal[];

    let users: { name: string; value: string }[] | undefined;

    let refreshUsers = async () => {
        let mainAgent = await mainAgentFactory();
        let result = await mainAgent.getUsers({ all: null });
        if ("ok" in result) {
            users = result.ok.map((user) => ({
                name: buildUserPseudonym(user.id),
                value: user.id.toString(),
            }));
        } else {
            console.error("Failed to get town owners: ", result);
            users = undefined;
        }
    };
    $: refreshUsers();

    let userIds = value.map((id) => id.toString());

    $: value = userIds.map((id) => Principal.fromText(id));
</script>

<MultiSelect items={users} bind:value={userIds} />
