<script lang="ts">
  import { FieldPosition } from "../models/FieldPosition";

  export let takenPositions: FieldPosition[];
  export let onPositionChange: (position: FieldPosition) => void;

  $: availablePositions = () =>
    Object.keys(FieldPosition).filter(
      (p) => !takenPositions.includes(FieldPosition[p])
    );
</script>

<select
  on:change={(e) => onPositionChange(FieldPosition[e.currentTarget.value])}
>
  <option value="">-</option>
  {#each availablePositions() as position}
    <option value={position}>
      {FieldPosition[position]}
    </option>
  {/each}
</select>
