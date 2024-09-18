<script lang="ts">
  export let width: number;
  export let height: number;
  export let pixelSize: number = 16;
  // Derived from https://github.com/giventofly/pixelit/blob/master/src/pixelit.js
  let pixelate = (sourceImage: HTMLImageElement, drawto: HTMLCanvasElement) => {
    let ctx = drawto.getContext("2d")!;
    drawto.width = width * pixelSize;
    drawto.height = height * pixelSize;
    let scaledW = width;
    let scaledH = height;

    //make temporary canvas to make new scaled copy
    const tempCanvas = document.createElement("canvas");

    // Set temp canvas width/height & hide (fixes higher scaled cutting off image bottom)
    tempCanvas.width = drawto.width;
    tempCanvas.height = drawto.height;
    tempCanvas.style.visibility = "hidden";
    tempCanvas.style.position = "fixed";
    tempCanvas.style.top = "0";
    tempCanvas.style.left = "0";

    // get the context
    const tempContext = tempCanvas.getContext("2d")!;
    // draw the image into the canvas
    tempContext.drawImage(sourceImage, 0, 0, scaledW, scaledH);
    document.body.appendChild(tempCanvas);
    //configs to pixelate
    ctx.imageSmoothingEnabled = false;

    //draw to final canvas
    //https://developer.mozilla.org/en-US/docs/Web/API/CanvasRenderingContext2D/drawImage
    ctx.drawImage(
      tempCanvas,
      0,
      0,
      scaledW,
      scaledH,
      0,
      0,
      width * pixelSize, //+ Math.max(24, 25 * this.scale),
      height * pixelSize //+ Math.max(24, 25 * this.scale)
    );
    //remove temp element
    tempCanvas.remove();
  };

  let drawto: HTMLCanvasElement;
  let sourceImage: HTMLImageElement;
  let fileInput: HTMLInputElement;

  function handleFileSelect() {
    const file = fileInput.files?.[0];
    if (file) {
      const reader = new FileReader();
      reader.onload = (e) => {
        sourceImage.src = e.target?.result as string;
        sourceImage.onload = () => pixelate(sourceImage, drawto);
      };
      reader.readAsDataURL(file);
    }
  }
</script>

<input
  type="file"
  accept="image/*"
  bind:this={fileInput}
  on:change={handleFileSelect}
/>
<img bind:this={sourceImage} style="display: none;" alt="source" />
<canvas bind:this={drawto} />
