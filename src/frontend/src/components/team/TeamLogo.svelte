<script lang="ts">
  export let team: { logoUrl: string; name: string };
  export let size: "sm" | "md" | "lg" | undefined;
</script>

<img
  class="logo {size ? `size-${size}` : ''}"
  src={team.logoUrl}
  alt="{team.name} Logo"
/>

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
