<script lang="ts">
    import LoadingButton from "./common/LoadingButton.svelte";
    import DaoAdmin from "./DaoAdmin.svelte";
    import AddScenario from "./scenario/AddScenario.svelte";
    import ScheduleSeason from "./season/ScheduleSeason.svelte";
    import TempInitialize from "./TempInitialize.svelte";
    import { BenevolentDictatorState } from "../ic-agent/declarations/league";
    import { identityStore } from "../stores/IdentityStore";
    import { userStore } from "../stores/UserStore";
    import { Accordion, AccordionItem } from "flowbite-svelte";
    import AddTeamTrait from "./team/AddTeamTrait.svelte";

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
        <Accordion>
            <AccordionItem>
                <span slot="header">Schedule Season</span>
                <ScheduleSeason />
            </AccordionItem>
            <AccordionItem>
                <span slot="header">Add Scenario</span>
                <AddScenario />
            </AccordionItem>
            <AccordionItem>
                <span slot="header">DAO Admin</span>
                <DaoAdmin />
            </AccordionItem>
            <AccordionItem>
                <span slot="header">Add Team Trait</span>
                <AddTeamTrait />
            </AccordionItem>
        </Accordion>
    {/if}
{/if}
