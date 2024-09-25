<script lang="ts">
  import { Principal } from "@dfinity/principal";

  import { toSvg } from "jdenticon";

  export let userId: Principal | string;
  export let size: "xs" | "sm" | "lg" | "xl" | "md" = "md";
  export let border: boolean = true;

  let pixelSize: number;
  switch (size) {
    case "xs":
      pixelSize = 12;
      break;
    case "sm":
      pixelSize = 16;
      break;
    case "md":
      pixelSize = 20;
      break;
    case "lg":
      pixelSize = 32;
      break;
    default:
      pixelSize = 48;
      break;
  }

  let userIdString = userId instanceof Principal ? userId.toString() : userId;
</script>

<div class="inline-block bg-gray-600 {border ? 'border' : ''}">
  {@html toSvg(userIdString, pixelSize)}
</div>
