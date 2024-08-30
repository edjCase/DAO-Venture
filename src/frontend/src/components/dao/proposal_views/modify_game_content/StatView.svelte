<script lang="ts">
  export let stats: {
    magic: bigint;
    maxHealth: bigint;
    speed: bigint;
    weaponId: string;
    defense: bigint;
    attack: bigint;
    health: bigint;
  };
</script>

<div>Health: {stats.health}</div>
<div>Max Health: {stats.maxHealth}</div>
<div>Attack: {stats.attack}</div>
<div>Defense: {stats.defense}</div>
<div>Speed: {stats.speed}</div>
<div>Magic: {stats.magic}</div>
<div>Weapon Id: {stats.weaponId}</div>
