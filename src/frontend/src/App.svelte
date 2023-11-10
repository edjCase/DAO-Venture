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
    <Route
      path="/match-groups/:matchGroupIdString"
      let:params
      component={MatchGroup}
    />
    <Route path="*" component={NotFound} />
  </Router>
</main>
