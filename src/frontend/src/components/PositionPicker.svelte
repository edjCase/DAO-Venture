<script lang="ts">
  import { FieldPosition } from "../models/FieldPosition";

  export let onPositionChange: (position: FieldPosition) => void;

  let onPositionChangeInternal = (event: Event) => {
    let target = event.currentTarget as HTMLSelectElement;
    let position = FieldPosition[target.value as keyof typeof FieldPosition];
    onPositionChange(position);
  };

  let positionOptions = Object.keys(FieldPosition).map((position) => {
    return {
      value: position,
      label: FieldPosition[position as keyof typeof FieldPosition],
    };
  });
</script>

<select on:change={onPositionChangeInternal}>
  <option value="">-</option>
  {#each positionOptions as position}
    <option value={position.value}>
      {position.label}
    </option>
  {/each}
</select>
