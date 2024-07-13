<script lang="ts">
    import LoadingButton from "./common/LoadingButton.svelte";
    import DaoAdmin from "./DaoAdmin.svelte";
    import AddScenario from "./scenario/AddScenario.svelte";
    import ScheduleSeason from "./season/ScheduleSeason.svelte";
    import TempInitialize from "./TempInitialize.svelte";
    import { BenevolentDictatorState } from "../ic-agent/declarations/main";
    import { userStore } from "../stores/UserStore";
    import { Accordion, AccordionItem, Badge, Tooltip } from "flowbite-svelte";
    import AddTeamTrait from "./team/AddTeamTrait.svelte";
    import { traitStore } from "../stores/TraitStore";

    $: user = $userStore;

    $: traits = $traitStore;

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
    {:else if "claimed" in bdfnState && bdfnState.claimed.toString() == user.id.toString()}
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
                <span slot="header">Team Traits</span>
                <div class="text-3xl">Current</div>
                {#if traits !== undefined}
                    {#each traits as trait}
                        <Badge large>{trait.name}</Badge>
                        <Tooltip>{trait.description}</Tooltip>
                    {/each}
                {/if}
                <div class="text-3xl mt-5">Add</div>
                <AddTeamTrait />
            </AccordionItem>
        </Accordion>
    {/if}
{/if}
