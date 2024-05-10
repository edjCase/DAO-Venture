<script lang="ts">
    import { Input, Label } from "flowbite-svelte";
    import { teamsAgentFactory } from "../../ic-agent/Teams";
    import { CreateTeamTraitRequest } from "../../ic-agent/declarations/teams";
    import LoadingButton from "../common/LoadingButton.svelte";
    import { traitStore } from "../../stores/TraitStore";

    let trait: CreateTeamTraitRequest = {
        id: "",
        name: "",
        description: "",
    };

    let addTrait = async () => {
        if (!trait) {
            console.error("Trait not loaded. Cannot add.");
            return;
        }
        let teamsAgent = await teamsAgentFactory();
        let result = await teamsAgent.createTeamTrait(trait);
        if ("ok" in result) {
            console.log("Created trait: ", trait);
            traitStore.refetch();
        } else {
            console.error("Failed to make trait: ", trait, result);
        }
    };
</script>

<Label>Id</Label>
<Input type="text" bind:value={trait.id} />
<Label>Name</Label>
<Input type="text" bind:value={trait.name} />
<Label>Description</Label>
<Input type="text" bind:value={trait.description} />
<LoadingButton onClick={addTrait}>Add Trait</LoadingButton>
