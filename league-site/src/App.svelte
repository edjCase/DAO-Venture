<script lang="ts">
  import { Router, Route } from "svelte-routing";
  import Home from "./routes/Home.svelte";
  import About from "./routes/About.svelte";
  import Game from "./routes/Game.svelte";
  import Games from "./routes/Games.svelte";
  import NotFound from "./routes/NotFound.svelte";
  import Header from "./components/Header.svelte";
</script>

<main>
  <Router>
    <Header/>
    <Route path="/" component={Home} />
    <Route path="/about" component={About} />
    <Route path="/game/:id" let:params component={Game} />
    <Route path="/games" component={Games} />
    <Route path="*" component={NotFound} />
  </Router>
</main>

<style>
main {
  text-align: center;
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