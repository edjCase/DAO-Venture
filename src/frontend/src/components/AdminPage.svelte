<script lang="ts">
    import LoadingButton from "./common/LoadingButton.svelte";
    import DaoAdmin from "./DaoAdmin.svelte";
    import AddScenario from "./scenario/AddScenario.svelte";
    import ScheduleSeason from "./season/ScheduleSeason.svelte";
    import TempInitialize from "./TempInitialize.svelte";
    import { BenevolentDictatorState } from "../ic-agent/declarations/league";
    import { identityStore } from "../stores/IdentityStore";
    import { userStore } from "../stores/UserStore";

    $: identity = $identityStore;

    let bdfnState: BenevolentDictatorState | undefined;
    userStore.subscribeBdfnState((state) => {
        bdfnState = state;
    });
</script>

{#if bdfnState !== undefined}
    {#if "open" in bdfnState}
        <LoadingButton onClick={userStore.claimBdfnRole}
            >Claim BDFN</LoadingButton
        >
    {:else if "claimed" in bdfnState && bdfnState.claimed.toString() == identity
                .getPrincipal()
                .toString()}
        <div>Welcome Benevolent Dictator</div>
        <div>
            <TempInitialize />
        </div>
        <div>
            <ScheduleSeason />
        </div>
        ---
        <div>
            <AddScenario />
        </div>
        ---
        <div>
            <DaoAdmin />
        </div>
    {/if}
{/if}
