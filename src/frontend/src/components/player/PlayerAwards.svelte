<script lang="ts">
  import { AtomOutline } from "flowbite-svelte-icons";
  import { Card } from "flowbite-svelte";

  // Define a new type for player awards
  type PlayerAward = {
    name: string;
    team: string;
    award: string;
    description: string;
  };

  let playerAwards: PlayerAward[] = [
    {
      name: "John Doe",
      team: "Team A",
      award: "Most Home Runs",
      description: "Player who got the most home runs",
    },
    {
      name: "Alice Smith",
      team: "Team B",
      award: "Marathon Runner",
      description: "Player who ran the furthest total distance on the field",
    },
    {
      name: "Bob Johnson",
      team: "Team C",
      award: "Strikeout King",
      description: "Player who recorded the most strikeouts",
    },
    {
      name: "Emily Davis",
      team: "Team D",
      award: "Iron Batter",
      description: "Player who got hit by the pitch the most times",
    },
    {
      name: "Charlie Brown",
      team: "Team E",
      award: "Golden Arm",
      description: "Pitcher with the most accurate throws leading to outs",
    },
    {
      name: "Diana Green",
      team: "Team F",
      award: "Butter Legs",
      description: "Player who stole the most bases",
    },
    {
      name: "Frank Hill",
      team: "Team G",
      award: "Eagle Eye",
      description: "Player with the most walks",
    },
    {
      name: "Grace Lee",
      team: "Team H",
      award: "Cannon Arm",
      description: "Outfielder with the most throws leading to outs at bases",
    },
    {
      name: "Henry Wilson",
      team: "Team I",
      award: "Wall Climber",
      description:
        "Player who made the most spectacular catches near the field boundaries",
    },
    {
      name: "Irene Taylor",
      team: "Team J",
      award: "Speedster Sprinter",
      description:
        "Player who recorded the fastest running speed between bases",
    },
    // Add more players and their awards
  ];
</script>
