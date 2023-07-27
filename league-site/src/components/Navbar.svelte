<script>
  import { Link } from "svelte-routing";
  import ThemeToggle from "./ThemeToggle.svelte";
</script>

<nav class="navbar">
  <div class="navbar-title">DAOBall</div>
  <div class="spacer" />

  <div class="navbar-nav">
    <div class="nav-item">
      <Link to="/" class="nav-link">Home</Link>
    </div>
    <div class="nav-item">
      <Link to="/games" class="nav-link">Games</Link>
    </div>
    <div class="nav-item">
      <Link to="/governance" class="nav-link">Governance</Link>
    </div>
    <div class="nav-item">
      <Link to="/news" class="nav-link">News</Link>
    </div>
    <div class="nav-item">
      <Link to="/about" class="nav-link">About</Link>
    </div>
  </div>

  <div class="social-links">
    <a class="social-link" target="_blank" href="https://dscvr.one">
      <img src="/images/dscvr.png" alt="DSCVR" />
    </a>
    <a
      class="social-link"
      target="_blank"
      href="https://github.com/edjcase/daoball"
    >
      <img src="/images/github.png" alt="Github" />
    </a>
  </div>
  <div class="spacer" />

  <div class="nav-item theme-toggle">
    <ThemeToggle />
  </div>
</nav>

<style>
  .spacer {
    flex-grow: 1;
  }
  .navbar {
    display: flex;
    justify-content: space-around;
    align-items: center;
    background-color: var(--color-primary);
    color: var(--color-text);
    padding: 10px 100px;
  }

  .navbar-title {
    text-transform: uppercase;
    font-size: 1.7rem;
    font-weight: bold;
    width: 100px;
  }
  .navbar-nav {
    display: flex;
    list-style: none;
    margin: 0;
    padding: 0;
  }

  .nav-item {
    margin-right: 10px;
    display: flex;
    align-items: center;
  }

  .social-links {
    margin: 0 10px;
    display: flex;
    flex-direction: row;
    justify-content: space-around;
  }
  .social-link {
    margin: 0 5px;
  }
  .social-link img {
    width: 24px;
    height: 24px;
  }

  :global(.nav-link) {
    color: var(--color-text);
    text-decoration: none;
    padding: 5px;
    border-radius: 5px;
  }

  :global(.nav-link:hover) {
    background-color: var(--color-secondary);
    color: var(--color-text);
  }

  .theme-toggle {
    margin-left: 30px;
  }
</style>
