<script lang="ts">
  import { Router, Route } from "svelte-routing";
  import Home from "./routes/Home.svelte";
  import NotFound from "./routes/NotFound.svelte";
  import Town from "./routes/Town.svelte";
  import Towns from "./routes/Towns.svelte";
  import Admin from "./routes/Admin.svelte";
  import About from "./routes/About.svelte";
  import HowToPlay from "./routes/HowToPlay.svelte";
  import Scenarios from "./routes/Scenarios.svelte";
  import UserProfile from "./routes/UserProfile.svelte";
  import BottomNavigation from "./components/common/BottomNavigation.svelte";
  import MyTown from "./routes/MyTown.svelte";
  import World from "./routes/World.svelte";
  import Navbar from "./components/common/Navbar.svelte";
</script>

<main class="p-5 max-w-xl mx-auto h-screen">
  <Router>
    <Navbar />
    <div class="pb-20">
      <Route path="/" component={Home} />
      <Route path="/scenarios" component={Scenarios} />
      <Route path="/profile" component={UserProfile} />
      <Route path="/my-town" component={MyTown} />
      <Route path="/towns" component={Towns} />
      <Route path="/towns/:townIdString" component={Town} />
      <Route path="/world" component={World} />
      <Route path="/how-to-play" component={HowToPlay} />
      <Route path="/about" component={About} />
      <Route path="/admin" component={Admin} />
      <Route path="*" component={NotFound} />
    </div>
    <BottomNavigation />
  </Router>
</main>
