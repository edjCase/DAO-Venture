<script lang="ts">
  import { Tweened, tweened } from "svelte/motion";
  import { linear } from "svelte/easing";

  type Location = { x: number; y: number };

  export let origin: Location;
  export let locations: Location[];

  const duration = 2000;
  let currentLocationX: Tweened<number>;
  let currentLocationY: Tweened<number>;

  $: {
    currentLocationX = tweened(origin.x, { duration, easing: linear });
    currentLocationY = tweened(origin.y, { duration, easing: linear });
    currentLocationY.set(origin.y);
    if (locations.length > 0) {
      currentLocationX.set(locations[0].x);
      currentLocationY.set(locations[0].y);
      if (locations.length > 1) {
        let i = 1;
        const interval = setInterval(() => {
          currentLocationX.set(locations[i].x);
          currentLocationY.set(locations[i].y);
          i++;
          if (i >= locations.length) {
            clearInterval(interval);
          }
        }, duration);
      }
    }
  }
</script>

<circle cx={$currentLocationX} cy={$currentLocationY} r="2" fill="white" />
