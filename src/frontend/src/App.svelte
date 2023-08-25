<script lang="ts">
  import { Router, Route } from "svelte-routing";
  import Home from "./routes/Home.svelte";
  import About from "./routes/About.svelte";
  import Match from "./routes/Match.svelte";
  import Matches from "./routes/Matches.svelte";
  import NotFound from "./routes/NotFound.svelte";
  import Header from "./components/Header.svelte";
  import News from "./routes/News.svelte";
</script>

<main>
  <Router>
    <Header />
    <Route path="/" component={Home} />
    <Route path="/about" component={About} />
    <Route path="/matches/:id" let:params component={Match} />
    <Route path="/matches" component={Matches} />
    <Route path="/news" component={News} />
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
