<script lang="ts">
  import {
    TabItem,
    Tabs,
    Label,
    Select,
    SelectOptionType,
  } from "flowbite-svelte";
  import ImageToPixelArt from "./common/ImageToPixelArt.svelte";
  import PixelArtEditor from "./common/PixelArtEditor.svelte";
  import {
    generatePixelGrid,
    PixelGridSize,
    resizePixelGrid,
  } from "../utils/PixelUtil";

  let sizeItems: SelectOptionType<number>[] = [
    { name: "16x16", value: 16 },
    { name: "32x32", value: 32 },
    { name: "64x64", value: 64 },
  ];
  let selectedSize: PixelGridSize = 32;
  let canvasGrid = generatePixelGrid(selectedSize, selectedSize);

  let resizeGrid = () => {
    canvasGrid = resizePixelGrid(canvasGrid, selectedSize);
  };
  let editorWidth = 512;
</script>

<Label>Size</Label>
<Select items={sizeItems} bind:value={selectedSize} on:change={resizeGrid} />
<Tabs>
  <TabItem title="Canvas" open>
    <PixelArtEditor
      pixels={canvasGrid}
      previewPixelSize={2}
      pixelSize={editorWidth / selectedSize}
    />
  </TabItem>
  <TabItem title="Pixelate Image">
    <ImageToPixelArt
      width={selectedSize}
      height={selectedSize}
      pixelSize={editorWidth / selectedSize}
      previewPixelSize={10}
    />
  </TabItem>
</Tabs>
