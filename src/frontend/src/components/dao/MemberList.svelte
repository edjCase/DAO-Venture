<script lang="ts">
    import { onDestroy } from "svelte";
    import { Principal } from "@dfinity/principal";
    import UserAvatar from "../user/UserAvatar.svelte";
    import UserPseudonym from "../user/UserPseudonym.svelte";
    import { userStore } from "../../stores/UserStore";
    import { User } from "../../ic-agent/declarations/users";

    export let teamId: string | Principal;

    let members: User[] = [];
    let unsubscribeToTeamMembers = () => {};

    $: {
        unsubscribeToTeamMembers(); // Unsubscribe from the old subscription
        unsubscribeToTeamMembers = userStore.subscribe((users) => {
            members = users.filter((user) => {
                return (
                    user.team[0]?.id.toString() === teamId.toString() &&
                    "owner" in user.team[0].kind
                );
            });
        });
    }

    onDestroy(() => {
        unsubscribeToTeamMembers();
    });
</script>

{#each members as member}
    <div class="border p-5">
        <UserAvatar userId={member.id} />
        <UserPseudonym userId={member.id} />
        <div>{member.id}</div>
    </div>
{/each}
