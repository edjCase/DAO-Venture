<script lang="ts">
  import { Image } from "../../../../ic-agent/declarations/main";

  export let image: Image;

  $: base64 = btoa(String.fromCharCode(...new Uint8Array(image.data)));
  $: mimeType = "image/png";
</script>

<div>
  <div>Image</div>
  <div>Id: {image.id}</div>
  <div>Kind: PNG</div>
  <div>
    <img src="data:{mimeType};base64,{base64}" alt="to upload" />
  </div>
</div>
