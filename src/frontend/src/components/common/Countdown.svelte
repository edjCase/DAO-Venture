<script lang="ts">
  import { onMount } from "svelte";

  export let title: string;
  export let date: Date;

  function timeTill(date: Date): [string, string, string, string] {
    let timeInMilliseconds = date.getTime() - new Date().getTime();
    if (timeInMilliseconds < 0) {
      return ["00", "00", "00", "00"];
    }
    let seconds = Math.floor(timeInMilliseconds / 1000);
    let minutes = Math.floor(seconds / 60);
    let hours = Math.floor(minutes / 60);
    let days = Math.floor(hours / 24);

    seconds = seconds % 60;
    minutes = minutes % 60;
    hours = hours % 24;

    // Pad the numbers with leading zeros if they are single digit
    const paddedSeconds = String(seconds).padStart(2, "0");
    const paddedMinutes = String(minutes).padStart(2, "0");
    const paddedHours = String(hours).padStart(2, "0");
    const paddedDays = String(days).padStart(2, "0");

    return [paddedDays, paddedHours, paddedMinutes, paddedSeconds];
  }
  let timeTillNextMatch = timeTill(date);
  onMount(() => {
    const interval = setInterval(() => {
      timeTillNextMatch = timeTill(date);
    }, 1000);
    return () => clearInterval(interval);
  });
</script>

<div class="p-5 mb-5">
  <div class="text-center text-4xl mb-2">{title}</div>
  <div class="flex w-64">
    <div class="flex flex-col w-1/4 items-center text-center">
      <span class="text-3xl">{timeTillNextMatch[0]}</span>
      <span class="text-xs">Days</span>
    </div>
    <div class="flex flex-col w-1/4 items-center text-center">
      <span class="text-3xl">{timeTillNextMatch[1]}</span>
      <span class="text-xs">Hours</span>
    </div>
    <div class="flex flex-col w-1/4 items-center text-center">
      <span class="text-3xl">{timeTillNextMatch[2]}</span>
      <span class="text-xs">Minutes</span>
    </div>
    <div class="flex flex-col w-1/4 items-center text-center">
      <span class="text-3xl">{timeTillNextMatch[3]}</span>
      <span class="text-xs">Seconds</span>
    </div>
  </div>
</div>
