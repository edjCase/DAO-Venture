<script lang="ts">
  export let state: {
    firstBase: [number] | [];
    secondBase: [number] | [];
    thirdBase: [number] | [];
  };
  let fillColor = "white";
</script>

<div>
  <svg width="60" height="50">
    <polygon
      points="45,25 55,35 45,45 35,35"
      fill={state.firstBase.length < 1 ? "none" : fillColor}
      stroke={fillColor}
      stroke-width="2"
    />
    <polygon
      points="30,10 40,20 30,30 20,20"
      fill={state.firstBase.length < 1 ? "none" : fillColor}
      stroke={fillColor}
      stroke-width="2"
    />
    <polygon
      points="15,25 25,35 15,45 5,35"
      fill={state.firstBase.length < 1 ? "none" : fillColor}
      stroke={fillColor}
      stroke-width="2"
    />
  </svg>
</div>
