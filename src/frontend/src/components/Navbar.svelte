<script>
  import { Link } from "svelte-routing";
  import ThemeToggle from "./ThemeToggle.svelte";
  import LoginButton from "./LoginButton.svelte";
</script>

<nav class="navbar">
  <ul class="navbar-nav">
    <li class="nav-item">
      <Link to="/" class="nav-link">Home</Link>
    </li>
    <li class="nav-item">
      <Link to="/matches" class="nav-link">Matches</Link>
    </li>
    <li class="nav-item">
      <a
        class="nav-link"
        target="_blank"
        href="https://mora.app/planet/a46fs-ryaaa-aaaan-qdcyq-cai">Blog</a
      >
    </li>
    <li>
      <ThemeToggle />
    </li>
    <li>
      <LoginButton />
    </li>
  </ul>
</nav>

<style>
  .navbar {
    display: flex;
    justify-content: space-between;
    align-items: center;
    background-color: var(--color-primary);
    color: var(--color-text);
    padding: 10px;
  }

  .navbar-nav {
    display: flex;
    list-style: none;
    margin: 0;
    padding: 0;
  }

  .nav-item {
    margin-right: 10px;
  }

  :global(.nav-link) {
    color: var(--color-text);
    text-decoration: none;
    padding: 5px;
    border-radius: 5px;
  }

  :global(.nav-link:hover) {
    background-color: var(--color-primary);
    color: var(--color-text);
  }
</style>
