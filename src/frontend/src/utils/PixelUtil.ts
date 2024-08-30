import { PixelImage } from "../ic-agent/declarations/main";

export type PixelGrid = PixelColor[][];

export type Rgb = [number, number, number];

type IndexOrTransparent = [number] | [];

export type PixelColor = Rgb | undefined;

export function encodePixelsToBase64(pixels: PixelGrid): string {
    return encodeImageToBase64(encodePixelsToImage(pixels));
};

export function decodeBase64ToPixels(base64: string, width: number, height: number): PixelGrid {
    return decodeImageToPixels(decodeBase64ToImage(base64), width, height);
};

export function encodeImageToBase64(image: PixelImage): string {
    const buffer = new ArrayBuffer(
        1 + // Palette size
        image.palette.length * 3 + // Palette colors
        image.indices.length // Indices
    );
    const view = new DataView(buffer);
    let offset = 0;

    // Write palette size
    view.setUint8(offset, image.palette.length);
    offset += 1;

    // Write palette colors
    image.palette.forEach(color => {
        view.setUint8(offset, color[0]); // R
        view.setUint8(offset + 1, color[1]); // G
        view.setUint8(offset + 2, color[2]); // B
        offset += 3;
    });

    // Write indices
    image.indices.forEach(index => {
        view.setUint8(offset, index[0] === undefined ? 255 : index[0]);
        offset += 1;
    });

    // Convert to Base64
    return btoa(String.fromCharCode.apply(null, new Uint8Array(buffer) as unknown as number[]));
}

export function decodeBase64ToImage(base64: string): PixelImage {
    const binaryString = atob(base64);
    const buffer = new ArrayBuffer(binaryString.length);
    const view = new DataView(buffer);

    // Fill the buffer
    for (let i = 0; i < binaryString.length; i++) {
        view.setUint8(i, binaryString.charCodeAt(i));
    }

    let offset = 0;

    // Read palette size
    const paletteSize = view.getUint8(offset);
    offset += 1;

    // Read palette colors
    const palette: Rgb[] = [];
    for (let i = 0; i < paletteSize; i++) {
        palette.push([
            view.getUint8(offset),
            view.getUint8(offset + 1),
            view.getUint8(offset + 2)
        ]);
        offset += 3;
    }

    // Read indices
    const indices: IndexOrTransparent[] = [];
    while (offset < buffer.byteLength) {
        const index = view.getUint8(offset);
        indices.push(index === 255 ? [] : [index]);
        offset += 1;
    }

    return { palette, indices };
}

export function encodePixelsToImage(pixels: PixelGrid): PixelImage {
    const palette: Rgb[] = [];
    const indices: IndexOrTransparent[] = [];

    pixels.flat().forEach(pixel => {
        let index: IndexOrTransparent = [];
        if (pixel !== undefined) {
            let i = palette.findIndex(color => colorsEqual(color, pixel));
            if (i === -1) {
                index = [palette.length];
                palette.push(pixel);
            }
        }
        indices.push(index);
    });
    if (palette.length >= 255) {
        throw new Error('Too many colors in palette. Max is 254.');
    }

    return { palette, indices };
}

export function decodeImageToPixels(data: PixelImage, width: number, height: number): PixelGrid {
    const pixels: PixelColor[] = data.indices.map(i => i[0] === undefined ? undefined : data.palette[i[0]]);

    const grid: PixelColor[][] = [];
    for (let y = 0; y < height; y++) {
        grid.push(pixels.slice(y * width, (y + 1) * width));
    }
    return grid;
}

function colorsEqual(a: Rgb, b: Rgb): boolean {
    return a[0] === b[0] && a[1] === b[1] && a[2] === b[2];
}