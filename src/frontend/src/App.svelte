<script lang="ts">
  import { Router, Route } from "svelte-routing";
  import Home from "./routes/Home.svelte";
  import NotFound from "./routes/NotFound.svelte";
  import Header from "./components/common/Header.svelte";
  import MatchGroup from "./routes/MatchGroup.svelte";
  import Team from "./routes/Team.svelte";
  import Teams from "./routes/Teams.svelte";
  import Schedule from "./routes/Schedule.svelte";
  import Admin from "./routes/Admin.svelte";
  import Player from "./routes/Player.svelte";
  import Players from "./routes/Players.svelte";
  import About from "./routes/About.svelte";
  import HowToPlay from "./routes/HowToPlay.svelte";
</script>

<main class="content">
  <Router>
    <Header />
    <div>
      <Route path="/" component={Home} />
      <Route path="/schedule" component={Schedule} />
      <Route path="/teams" component={Teams} />
      <Route path="/teams/:teamIdString" component={Team} />
      <Route path="/players" component={Players} />
      <Route path="/players/:playerIdString" component={Player} />
      <Route path="/match-groups/:matchGroupIdString" component={MatchGroup} />
      <Route path="/HowToPlay" component={HowToPlay} />
      <Route path="/about" component={About} />
      <Route path="/admin" component={Admin} />
      <Route path="*" component={NotFound} />
    </div>
  </Router>
</main>

<style global lang="postcss">
  @tailwind base;
  @tailwind components;
  @tailwind utilities;
  .content {
    padding: 20px;
  }
</style>
