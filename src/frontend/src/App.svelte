<script lang="ts">
  import { Router, Route } from "svelte-routing";
  import Home from "./routes/Home.svelte";
  import NotFound from "./routes/NotFound.svelte";
  import Header from "./components/Header.svelte";
  import MatchGroup from "./routes/MatchGroup.svelte";
  import Team from "./routes/Team.svelte";
</script>

<main>
  <Router>
    <Header />
    <div class="body">
      <Route path="/" component={Home} />
      <Route path="/match-groups/:matchGroupIdString" component={MatchGroup} />
      <Route path="/teams/:teamIdString" component={Team} />
      <Route path="*" component={NotFound} />
    </div>
  </Router>
</main>

<style global lang="postcss">
  @tailwind base;
  @tailwind components;
  @tailwind utilities;
  .body {
    padding: 0 10rem;
  }
</style>
