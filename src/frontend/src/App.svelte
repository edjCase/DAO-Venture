<script lang="ts">
  import { Router, Route } from "svelte-routing";
  import Home from "./routes/Home.svelte";
  import NotFound from "./routes/NotFound.svelte";
  import About from "./routes/About.svelte";
  import HowToPlay from "./routes/HowToPlay.svelte";
  import UserProfile from "./routes/UserProfile.svelte";
  import BottomNavigation from "./components/common/BottomNavigation.svelte";
  import Dao from "./routes/Dao.svelte";
  import Navbar from "./components/common/Navbar.svelte";
  import JoinGame from "./routes/JoinGame.svelte";
</script>

<main class="p-5 max-w-xl mx-auto h-screen">
  <Router>
    <Navbar />
    <div class="pb-20">
      <Route path="/" component={Home} />
      <Route path="/dao" component={Dao} />
      <Route path="/profile" component={UserProfile} />
      <Route path="/join/:gameIdString" component={JoinGame} />
      <Route path="/how-to-play" component={HowToPlay} />
      <Route path="/about" component={About} />
      <Route path="*" component={NotFound} />
    </div>
    <BottomNavigation />
  </Router>
</main>
