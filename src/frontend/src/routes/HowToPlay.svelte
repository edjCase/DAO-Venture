<script lang="ts">
  import { slide } from "svelte/transition";

  const howToPlaySections = [
    {
      title: "Character Creation",
      content: [
        "Choose a race and class for your character.",
        "Each combination provides unique traits and starting bonuses.",
      ],
    },
    {
      title: "Game Flow",
      content: [
        "Select an area to explore (e.g., Enchanted Forest, Ancient Ruins).",
        "Face random scenarios within the chosen area.",
        "Make decisions based on the options presented.",
        "Engage in combat when necessary.",
        "Progress through multiple areas to reach the final challenge.",
      ],
    },
    {
      title: "Scenarios",
      content: [
        "Read the scenario description carefully.",
        "Choose from available options, which may be influenced by your character's traits, items, or abilities.",
        "Face the consequences of your choices, which can include rewards, penalties, or combat.",
      ],
    },
    {
      title: "Combat",
      content: [
        "Select from a randomized subset of abilities each turn.",
        "Use your character's traits and items strategically.",
        "Defeat enemies to progress and earn rewards.",
      ],
    },
    {
      title: "Progression",
      content: [
        "Unlock new races, classes, traits, and items through gameplay.",
        "Earn tokens for participation and progression.",
        "Collect NFTs for achievements and milestones.",
      ],
    },
    {
      title: "Game End",
      content: [
        "Reach the Forgotten Citadel for the final challenge.",
        "Make a world-altering decision to conclude your run.",
      ],
    },
  ];

  let activeSection: number | null = null;

  function toggleSection(index: number) {
    activeSection = activeSection === index ? null : index;
  }
</script>

<div class="max-w-2xl mx-auto p-4 bg-gray-100 rounded-lg shadow-md">
  <h1 class="text-3xl font-bold mb-6 text-center text-gray-800">
    How to Play DAOventure
  </h1>

  {#each howToPlaySections as section, index}
    <div class="mb-4">
      <button
        on:click={() => toggleSection(index)}
        class="w-full text-left p-4 bg-white rounded-lg shadow hover:shadow-md transition-shadow duration-200 focus:outline-none focus:ring-2 focus:ring-blue-500"
      >
        <div class="flex justify-between items-center">
          <h2 class="text-xl font-semibold text-gray-700">{section.title}</h2>
          <svg
            class="w-6 h-6 text-gray-500 transform transition-transform duration-200 {activeSection ===
            index
              ? 'rotate-90'
              : ''}"
            fill="none"
            stroke="currentColor"
            viewBox="0 0 24 24"
            xmlns="http://www.w3.org/2000/svg"
          >
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M9 5l7 7-7 7"
            ></path>
          </svg>
        </div>
      </button>

      {#if activeSection === index}
        <div
          transition:slide={{ duration: 300 }}
          class="mt-2 p-4 bg-white rounded-lg shadow-inner"
        >
          <ul class="list-disc pl-5 space-y-2">
            {#each section.content as item}
              <li class="text-gray-600">{item}</li>
            {/each}
          </ul>
        </div>
      {/if}
    </div>
  {/each}

  <p class="mt-6 text-center text-gray-600 italic">
    Remember, each playthrough is unique due to randomized scenarios and
    decisions. Good luck on your adventure!
  </p>
</div>
