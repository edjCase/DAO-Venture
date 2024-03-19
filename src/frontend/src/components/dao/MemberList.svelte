<script lang="ts">
    import { onMount } from "svelte";
    import UserAvatar from "../user/UserAvatar.svelte";
    import UserPseudonym from "../user/UserPseudonym.svelte";
    import { User } from "../../ic-agent/declarations/users";
    import { usersAgentFactory } from "../../ic-agent/Users";

    export let teamId: bigint;

    let members: User[] = [];

    let getUsers = async () => {
        let usersAgent = await usersAgentFactory();
        let users = await usersAgent.getAll();
        members = users.filter((user) => {
            return (
                user.team[0]?.id.toString() === teamId.toString() &&
                "owner" in user.team[0].kind
            );
        });
    };

    onMount(getUsers);
</script>

{#each members as member}
    <div class="border p-5">
        <UserAvatar userId={member.id} />
        <UserPseudonym userId={member.id} />
        <div>{member.id}</div>
    </div>
{/each}
