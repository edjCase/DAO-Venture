<script lang="ts">
    import { onMount } from "svelte";
    import { User } from "../../ic-agent/declarations/users";
    import UserAvatar from "./UserAvatar.svelte";
    // import { usersAgentFactory } from "../../ic-agent/Users";
    import UserPseudonym from "./UserPseudonym.svelte";

    let users: User[] = [];

    let getTopUsers = async () => {
        // let userAgent = await usersAgentFactory();
        // users = await userAgent.getTopUsers();
        users = [];
    };

    onMount(getTopUsers);
</script>

{#each users as user}
    <div>
        <UserAvatar userId={user.id} />
        <UserPseudonym userId={user.id} />
        <p>{user.points}</p>
    </div>
{/each}
