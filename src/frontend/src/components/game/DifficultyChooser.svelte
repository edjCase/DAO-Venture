<script lang="ts">
  import { Button, ButtonGroup } from "flowbite-svelte";
  import { Difficulty } from "../../ic-agent/declarations/main";

  export let value: Difficulty;

  let changeDifficulty = (difficulty: Difficulty) => async () => {
    value = difficulty;
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
