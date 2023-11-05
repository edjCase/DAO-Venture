<script lang="ts">
  import { Router, Route } from "svelte-routing";
  import Home from "./routes/Home.svelte";
  import NotFound from "./routes/NotFound.svelte";
  import Header from "./components/Header.svelte";
  import MatchGroup from "./routes/MatchGroup.svelte";
</script>

<main>
  <Router>
    <Header />
    <Route path="/" component={Home} />
    <Route path="/session/:matchGroupId" let:params component={MatchGroup} />
    <Route path="*" component={NotFound} />
  </Router>
</main>

<style>
  main {
    padding: 1em;
    max-width: 240px;
    margin: 0 auto;
  }

  @media (min-width: 640px) {
    main {
      max-width: none;
    }
  }
</style>
