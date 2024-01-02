<script>
  import { Link } from "svelte-routing";
  import LoginButton from "./LoginButton.svelte";
  import UpdateLeagueCanistersButton from "./UpdateLeagueCanistersButton.svelte";
</script>

<nav class="navbar">
  <ul class="navbar-nav">
    <li class="nav-item">
      <Link to="/" class="nav-link button-style">Home</Link>
    </li>
    <li class="nav-item">
      <Link to="/teams" class="nav-link button-style">Teams</Link>
    </li>
    <li class="nav-item">
      <Link to="/schedule" class="nav-link button-style">Schedule</Link>
    </li>
    <li class="nav-item">
      <a
        class="nav-link button-style"
        target="_blank"
        href="https://mora.app/planet/a46fs-ryaaa-aaaan-qdcyq-cai"
      >
        Blog &#8599;
      </a>
    </li>
    <li>
      <a
        class="nav-link button-style"
        target="_blank"
        href="https://dscvr.one/p/daoball"
      >
        DSCVR &#8599;
      </a>
    </li>
    <li>
      <a
        class="nav-link button-style"
        target="_blank"
        href="https://github.com/edjcase/daoball"
      >
        Github &#8599;
      </a>
    </li>
    <li>
      <LoginButton />
    </li>
    <li>
      <UpdateLeagueCanistersButton />
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
    border-top: solid 4px var(--color-accent);
  }

  .navbar-nav {
    display: flex;
    list-style: none;
    margin: 0;
    padding: 0;
    flex-wrap: wrap;
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
