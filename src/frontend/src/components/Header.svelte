<script>
  import Navbar from "./Navbar.svelte";
</script>

<div class="header">
  <div class="header-logo">DAOBall</div>
</div>

<Navbar />

<style>
  .header {
    background-color: var(--color-bg); /* Use the background color variable */
    text-align: center;
    padding: 1rem 0 1rem 0; /* Top and bottom padding */
  }
  .header-logo {
    font-family: "Exo 2", sans-serif;
    color: var(--color-accent); /* Subdued teal color */
    font-size: 4rem;
    font-weight: 800;
    text-transform: uppercase;
    text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.5);
    margin: 0;
    padding: 0.5rem;
  }
</style>
