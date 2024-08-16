<script lang="ts">
  import { onMount } from "svelte";

  export let size: "xs" | "sm" | "md" | "lg" | "xl";
  export let characterClass: "warrior" | "mage" | "archer" | "rogue";
  export let seed: number;

  $: sizeClass = {
    xs: "w-12 h-12",
    sm: "w-16 h-16",
    md: "w-20 h-20",
    lg: "w-36 h-36",
    xl: "w-48 h-48",
  }[size];

  let character: string | undefined;

  function generateCharacter(seed: number): string {
    const canvas = document.createElement("canvas");
    canvas.width = 32;
    canvas.height = 32;
    const ctx = canvas.getContext("2d");
    if (!ctx) return "";

    const random = (max: number) =>
      Math.floor((Math.sin(seed++) + 1) * 10000) % max;

    // Clear canvas
    ctx.clearRect(0, 0, 32, 32);

    // Generate color palette
    const shirtColor = `hsl(${random(360)}, ${50 + random(50)}%, ${40 + random(20)}%)`;
    const pantsColor = `hsl(${random(360)}, ${50 + random(50)}%, ${40 + random(20)}%)`;
    const hatColor = `hsl(${random(360)}, ${50 + random(50)}%, ${40 + random(20)}%)`;

    // Draw body
    ctx.fillStyle = shirtColor;
    ctx.fillRect(8, 12, 16, 10);

    // Draw pants (split vertically)
    ctx.fillStyle = pantsColor;
    ctx.fillRect(8, 22, 7, 10);
    ctx.fillRect(17, 22, 7, 10);

    // Draw head
    ctx.fillStyle = "#FCD7B8"; // Skin color
    ctx.fillRect(10, 6, 12, 10);

    // Draw eyes
    ctx.fillStyle = "white";
    ctx.fillRect(12, 9, 2, 2);
    ctx.fillRect(18, 9, 2, 2);
    ctx.fillStyle = "black";
    ctx.fillRect(13, 10, 1, 1);
    ctx.fillRect(19, 10, 1, 1);

    // Draw mouth
    ctx.fillRect(14, 14, 4, 1);

    // Draw hat
    ctx.fillStyle = hatColor;
    ctx.fillRect(8, 4, 16, 4);

    // Draw class-specific weapon
    switch (characterClass) {
      case "warrior":
        // Sword blade
        ctx.fillStyle = "black";
        ctx.fillRect(26, 14, 3, 12);
        // Sword hilt
        ctx.fillStyle = "#8B4513"; // Brown color for hilt
        ctx.fillRect(25, 22, 5, 2);
        break;
      case "mage":
        ctx.fillStyle = "black";
        ctx.fillRect(26, 14, 3, 14); // Staff
        ctx.fillStyle = "purple";
        ctx.fillRect(26, 14, 4, 4); // Staff top
        break;
      case "archer":
        ctx.fillStyle = "black";
        // Vertical line (bow string)
        ctx.fillRect(26, 14, 2, 14);

        // Sideways arch (bow)
        ctx.beginPath();
        ctx.moveTo(26, 14);
        ctx.quadraticCurveTo(35, 21, 26, 28);
        ctx.lineWidth = 2;
        ctx.strokeStyle = "black";
        ctx.stroke();
        break;
      case "rogue":
        // Dagger blade
        ctx.fillStyle = "black";
        ctx.fillRect(26, 14, 4, 8);
        // Dagger hilt
        ctx.fillStyle = "#8B4513"; // Brown color for hilt
        ctx.fillRect(25, 18, 6, 2);
        break;
    }

    return canvas.toDataURL();
  }

  function handleGenerate(): void {
    character = generateCharacter(seed);
  }

  onMount(() => {
    handleGenerate();
  });
</script>

<img
  src={character}
  alt="Character Avatar"
  class="{sizeClass} border border-gray-300 rounded"
  style="image-rendering: pixelated;"
/>
