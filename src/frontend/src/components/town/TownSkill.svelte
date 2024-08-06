<script lang="ts">
    import { Skill } from "../../ic-agent/declarations/main";

    export let name: string;
    export let skill: Skill;
</script>

<div>
    <div>{name}</div>
    <div>Tech Level: {skill.techLevel}</div>
    <div>Proficiency Multiplier: {skill.proficiencyMultiplier.toFixed(2)}</div>
</div>
