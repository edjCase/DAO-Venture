<script lang="ts">
  export let team: { logoUrl: string; name: string } | undefined;
  export let size: "sm" | "md" | "lg" | undefined;

  let logoUrl = team?.logoUrl || "/images/team-logos/unknown.png";
  let alt = team?.name || "Undetermined";
</script>

<img class="logo {size ? `size-${size}` : ''}" src={logoUrl} {alt} />

<style>
  .logo {
    background-color: rgba(120, 120, 120, 0.5);
    border-radius: 25%;
    padding: 5px;
  }

  .size-sm {
    width: 50px;
    height: 50px;
  }
  .size-md {
    width: 100px;
    height: 100px;
  }
  .size-lg {
    width: 150px;
    height: 150px;
  }
</style>
