<script lang="ts">
  import { Router, Route } from "svelte-routing";
  import Home from "./routes/Home.svelte";
  import NotFound from "./routes/NotFound.svelte";
  import MatchGroup from "./routes/MatchGroup.svelte";
  import Team from "./routes/Team.svelte";
  import Teams from "./routes/Teams.svelte";
  import Schedule from "./routes/Schedule.svelte";
  import Admin from "./routes/Admin.svelte";
  import About from "./routes/About.svelte";
  import HowToPlay from "./routes/HowToPlay.svelte";
  import Scenarios from "./routes/Scenarios.svelte";
  import Matches from "./routes/Matches.svelte";
  import UserProfile from "./routes/UserProfile.svelte";
  import BottomNavigation from "./components/common/BottomNavigation.svelte";
  import MyTeam from "./routes/MyTeam.svelte";
  import League from "./routes/League.svelte";
  import Navbar from "./components/common/Navbar.svelte";
</script>

<main class="p-5 max-w-xl mx-auto h-screen">
  <Router>
    <Navbar />
    <div class="pb-20">
      <Route path="/" component={Home} />
      <Route path="/scenarios" component={Scenarios} />
      <Route path="/matches" component={Matches} />
      <Route path="/profile" component={UserProfile} />
      <Route path="/schedule" component={Schedule} />
      <Route path="/my-team" component={MyTeam} />
      <Route path="/teams" component={Teams} />
      <Route path="/teams/:teamIdString" component={Team} />
      <Route path="/league" component={League} />
      <Route path="/match-groups/:matchGroupIdString" component={MatchGroup} />
      <Route path="/how-to-play" component={HowToPlay} />
      <Route path="/about" component={About} />
      <Route path="/admin" component={Admin} />
      <Route path="*" component={NotFound} />
    </div>
    <BottomNavigation />
  </Router>
</main>
