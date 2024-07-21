<script lang="ts">
    import LoadingButton from "./common/LoadingButton.svelte";
    import DaoAdmin from "./DaoAdmin.svelte";
    import AddScenario from "./scenario/AddScenario.svelte";
    import { BenevolentDictatorState } from "../ic-agent/declarations/main";
    import { userStore } from "../stores/UserStore";
    import { Accordion, AccordionItem } from "flowbite-svelte";

    $: user = $userStore;

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
    {:else if "claimed" in bdfnState && bdfnState.claimed.toString() == user?.id.toString()}
        <div>Welcome Benevolent Dictator</div>
        <Accordion>
            <AccordionItem>
                <span slot="header">Add Scenario</span>
                <AddScenario />
            </AccordionItem>
            <AccordionItem>
                <span slot="header">DAO Admin</span>
                <DaoAdmin />
            </AccordionItem>
        </Accordion>
    {/if}
{/if}
