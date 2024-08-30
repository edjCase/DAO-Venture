<script lang="ts">
  import { Button, ButtonGroup } from "flowbite-svelte";
  import { Difficulty } from "../../ic-agent/declarations/main";
  import { mainAgentFactory } from "../../ic-agent/Main";
  import { currentGameStore } from "../../stores/CurrentGameStore";

  export let value: Difficulty;
  export let disabled: boolean = true;

  let changeDifficulty = (difficulty: Difficulty) => async () => {
    if (disabled) return;
    value = difficulty;
    let mainAgent = await mainAgentFactory();
    let result = await mainAgent.changeGameDifficulty(difficulty);
    if ("ok" in result) {
      currentGameStore.refetch();
    } else {
      console.error("Failed to change difficulty", result);
    }
  };
</script>

<div>
  <ButtonGroup>
    <Button
      outline={!("easy" in value)}
      color="green"
      on:click={changeDifficulty({ easy: null })}
    >
      Easy
    </Button>
    <Button
      outline={!("normal" in value)}
      color="yellow"
      on:click={changeDifficulty({ normal: null })}
    >
      Normal
    </Button>
    <Button
      outline={!("hard" in value)}
      color="red"
      on:click={changeDifficulty({ hard: null })}
    >
      Hard
    </Button>
  </ButtonGroup>
</div>
