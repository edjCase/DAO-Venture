<script lang="ts">
    import { CheckSolid, FileCopyOutline } from "flowbite-svelte-icons";
    import LoginButton from "../components/common/LoginButton.svelte";
    import { User } from "../ic-agent/declarations/users";
    import { identityStore } from "../stores/IdentityStore";
    import { userStore } from "../stores/UserStore";
    import { teamStore } from "../stores/TeamStore";

    $: identity = $identityStore;
    $: teams = $teamStore;

    let user: User | undefined;
    let idCopied = false;

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
    $: coOwner = user?.team[0]?.kind && "owner" in user.team[0].kind;

    let copyPrincipal = () => {
        if (!identity.getPrincipal().isAnonymous()) {
            idCopied = true;
            navigator.clipboard.writeText(identity.getPrincipal().toString());
            setTimeout(() => {
                idCopied = false;
            }, 2000); // wait for 2 seconds
        }
    };
</script>

{#if user}
    <div>
        <div>Id:</div>
        <div class="flex items-center">
            <div class="text-sm text-center">
                {identity.getPrincipal().toString()}
            </div>

            {#if idCopied}
                <CheckSolid size="lg" />
            {:else}
                <FileCopyOutline on:click={copyPrincipal} size="lg" />
            {/if}
        </div>
        <div>Points: {user.points}</div>
        {#if team}
            <div>Team: {team.name}</div>
            <div>Co-owner: {coOwner ? "Yes" : "No"}</div>
        {:else}
            <div>Team: None</div>
        {/if}
    </div>
{/if}

<LoginButton />
