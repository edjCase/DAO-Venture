<script lang="ts">
  import { Router, Route } from "svelte-routing";
  import Home from "./routes/Home.svelte";
  import NotFound from "./routes/NotFound.svelte";
  import MatchGroup from "./routes/MatchGroup.svelte";
  import Town from "./routes/Town.svelte";
  import Towns from "./routes/Towns.svelte";
  import Schedule from "./routes/Schedule.svelte";
  import Admin from "./routes/Admin.svelte";
  import About from "./routes/About.svelte";
  import HowToPlay from "./routes/HowToPlay.svelte";
  import Scenarios from "./routes/Scenarios.svelte";
  import Matches from "./routes/Matches.svelte";
  import UserProfile from "./routes/UserProfile.svelte";
  import BottomNavigation from "./components/common/BottomNavigation.svelte";
  import MyTown from "./routes/MyTown.svelte";
  import League from "./routes/League.svelte";
  import Navbar from "./components/common/Navbar.svelte";
  import TopPredictors from "./routes/TopPredictors.svelte";
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
      <Route path="/my-town" component={MyTown} />
      <Route path="/towns" component={Towns} />
      <Route path="/towns/:townIdString" component={Town} />
      <Route path="/league" component={League} />
      <Route path="top-predictors" component={TopPredictors} />
      <Route path="/match-groups/:matchGroupIdString" component={MatchGroup} />
      <Route path="/how-to-play" component={HowToPlay} />
      <Route path="/about" component={About} />
      <Route path="/admin" component={Admin} />
      <Route path="*" component={NotFound} />
    </div>
    <BottomNavigation />
  </Router>
</main>
