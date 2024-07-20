<script lang="ts">
    import { TrainContent } from "../../../../ic-agent/declarations/main";
    import { fieldPositionToString } from "../../../../models/FieldPosition";
    import { skillToString } from "../../../../models/Skill";
    import { playerStore } from "../../../../stores/PlayerStore";
    import { toJsonString } from "../../../../utils/StringUtil";

    export let content: TrainContent;
    export let townId: bigint;

    // TODO this doesn't work for executed proposals, since its the current level
    let currentLevel: bigint | undefined;
    playerStore.subscribe((players) => {
        let player = players?.find(
            (p) =>
                p.townId == townId &&
                Object.keys(p.position)[0] == Object.keys(content.position)[0],
        );
        if (player) {
            if ("battingAccuracy" in content.skill) {
                currentLevel = player.skills.battingAccuracy;
            } else if ("battingPower" in content.skill) {
                currentLevel = player.skills.battingPower;
            } else if ("catching" in content.skill) {
                currentLevel = player.skills.catching;
            } else if ("defense" in content.skill) {
                currentLevel = player.skills.defense;
            } else if ("speed" in content.skill) {
                currentLevel = player.skills.speed;
            } else if ("throwingAccuracy" in content.skill) {
                currentLevel = player.skills.throwingAccuracy;
            } else if ("throwingPower" in content.skill) {
                currentLevel = player.skills.throwingPower;
            } else {
                throw new Error(
                    "Invalid skill: " + toJsonString(content.skill),
                );
            }
        }
    });
</script>

{#if !currentLevel}
    <div></div>
{:else}
    <div>
        +1 {skillToString(content.skill)} for {fieldPositionToString(
            content.position,
        )} (level
        {currentLevel} -> {currentLevel + BigInt(1)})
    </div>
    <div>Cost: {currentLevel + BigInt(1)} 💰</div>
{/if}
