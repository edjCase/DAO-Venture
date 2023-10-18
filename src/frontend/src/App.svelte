<script lang="ts">
  import { Router, Route } from "svelte-routing";
  import Home from "./routes/Home.svelte";
  import Match from "./routes/Match.svelte";
  import Matches from "./routes/Matches.svelte";
  import NotFound from "./routes/NotFound.svelte";
  import Header from "./components/Header.svelte";
</script>

<main>
  <Router>
    <Header />
    <Route path="/" component={Home} />
    <Route path="/matches/:id" let:params component={Match} />
    <Route path="/matches" component={Matches} />
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
