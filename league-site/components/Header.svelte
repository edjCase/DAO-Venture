
<script>
    import Navbar from "./Navbar.svelte";
  </script>
  
  <div class="header-container">
    <div class="spacer"></div>
    <div class="name-header">DAOBall</div>
  
    <div class="spacer"></div>
  
    <div class="social-links">
      <a class="social-link" target="_blank" href="https://dscvr.one">DSCVR</a>
      <a class="social-link" target="_blank" href="https://github.com/edjcase/daoball">Github</a>
    </div>
  </div>
  
  <Navbar />
  <style>
    .header-container {
      display: flex;
      flex-direction: row;
      justify-content: center;
      align-items: center;
    }
  
    .name-header {
      color: #ff3e00;
      text-transform: uppercase;
      font-size: 4em;
      font-weight: 100;
    }
  
    .spacer {
      flex-grow: 1;
    }
  
    .social-links {
        padding-right: 50px;
    }
    .social-link {
        display: block;
    }
  </style>