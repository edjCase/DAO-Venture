<script lang="ts">
  import { FieldPositionEnum } from "../../models/FieldPosition";

  export let onPositionChange: (position: FieldPositionEnum) => void;

  let onPositionChangeInternal = (event: Event) => {
    let target = event.currentTarget as HTMLSelectElement;
    let position =
      FieldPositionEnum[target.value as keyof typeof FieldPositionEnum];
    onPositionChange(position);
  };

  let positionOptions = Object.keys(FieldPositionEnum).map((position) => {
    return {
      value: position,
      label: FieldPositionEnum[position as keyof typeof FieldPositionEnum],
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
