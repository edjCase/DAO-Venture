<script lang="ts">
    import { TextInputScenarioOutcome } from "../../../ic-agent/declarations/main";

    export let outcome: TextInputScenarioOutcome;
</script>

<div class="text-xl text-center mb-8">
    Chosen Value
    <div>{outcome.text}</div>
</div>
