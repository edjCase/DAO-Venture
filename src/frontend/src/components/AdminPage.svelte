<script lang="ts">
    import DaoAdmin from "./DaoAdmin.svelte";
    import AddScenario from "./scenario/AddScenario.svelte";
    import { userStore } from "../stores/UserStore";
    import { Accordion, AccordionItem } from "flowbite-svelte";
    import { worldStore } from "../stores/WorldStore";

    $: user = $userStore;

    $: world = $worldStore;
</script>

{#if user !== undefined && world !== undefined && world.progenitor === user.id}
    <div>Welcome Progenitor</div>
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
