import { PixelData, PixelImage } from "../ic-agent/declarations/main";

export type PixelGrid = PixelColor[][];

export type Rgb = [number, number, number];


export type PixelColor = Rgb | undefined;

export function encodePixelsToBase64(pixels: PixelGrid): string {
    return encodeImageToBase64(encodePixelsToImage(pixels));
};

export function decodeBase64ToPixels(base64: string, width: number, height: number): PixelGrid {
    return decodeImageToPixels(decodeBase64ToImage(base64), width, height);
};
function encodeLEB128(value: number): number[] {
    const result: number[] = [];
    while (true) {
        const byte = value & 0x7f;
        value >>= 7;
        if (value === 0) {
            result.push(byte);
            break;
        }
        result.push(byte | 0x80);
    }
    return result;
}

function decodeLEB128(bytes: Uint8Array, offset: number): [number, number] {
    let result = 0;
    let shift = 0;
    let bytesRead = 0;
    while (true) {
        const byte = bytes[offset + bytesRead];
        result |= (byte & 0x7f) << shift;
        bytesRead++;
        if ((byte & 0x80) === 0) {
            break;
        }
        shift += 7;
    }
    return [result, bytesRead];
}

export function encodeImageToBase64(image: PixelImage): string {
    const buffer = new ArrayBuffer(
        1 + // Palette size
        image.palette.length * 3 + // Palette colors
        image.pixelData.reduce((acc, data) => acc + encodeLEB128(Number(data.count)).length + 1, 0) // LEB128 counts + indices
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

    // Write pixel data
    image.pixelData.forEach(data => {
        const countBytes = encodeLEB128(Number(data.count));
        countBytes.forEach(byte => {
            view.setUint8(offset, byte);
            offset += 1;
        });
        view.setUint8(offset, data.paletteIndex[0] === undefined ? 255 : Number(data.paletteIndex[0]));
        offset += 1;
    });

    // Convert to Base64
    return btoa(String.fromCharCode.apply(null, new Uint8Array(buffer) as unknown as number[]));
}

export function decodeBase64ToImage(base64: string): PixelImage {
    const binaryString = atob(base64);
    const bytes = new Uint8Array(binaryString.length);
    for (let i = 0; i < binaryString.length; i++) {
        bytes[i] = binaryString.charCodeAt(i);
    }

    let offset = 0;

    // Read palette size
    const paletteSize = bytes[offset];
    offset += 1;

    // Read palette colors
    const palette: Rgb[] = [];
    for (let i = 0; i < paletteSize; i++) {
        palette.push([
            bytes[offset],
            bytes[offset + 1],
            bytes[offset + 2]
        ]);
        offset += 3;
    }

    // Read pixel data
    const pixelData: PixelData[] = [];
    while (offset < bytes.length) {
        const [count, bytesRead] = decodeLEB128(bytes, offset);
        offset += bytesRead;
        const index = bytes[offset];
        pixelData.push({
            count: BigInt(count),
            paletteIndex: index === 255 ? [] : [index]
        });
        offset += 1;
    }

    return { palette, pixelData };
}
export function encodePixelsToImage(pixels: PixelGrid): PixelImage {
    const palette: Rgb[] = [];
    const pixelData: PixelData[] = [];


    let currentColor: PixelColor = undefined;
    let pushAndReset = () => {
        let paletteIndex: [number] | [] = [];
        if (currentColor !== undefined) {
            let currentColorIndex = palette.findIndex((c) => colorsEqual(c, currentColor));
            if (currentColorIndex === -1) {
                throw new Error('Color not found in palette: ' + currentColor);
            };
            paletteIndex = [currentColorIndex];
        }
        pixelData.push({
            count: BigInt(currentCount),
            paletteIndex: paletteIndex
        });
        currentCount = 1;
    };

    let currentCount = 0;

    pixels.flat().forEach(pixel => {
        if (!colorsEqual(currentColor, pixel)) {
            if (currentCount > 0) {
                pushAndReset();
            }
            currentColor = pixel;
            if (pixel !== undefined && !palette.some(color => colorsEqual(color, pixel))) {
                palette.push(pixel);
            }
        } else {
            currentCount++;
        }
    });

    // Add the last run
    if (currentCount > 0) {
        pushAndReset();
    }

    if (palette.length >= 255) {
        throw new Error('Too many colors in palette. Max is 254.');
    }

    return { palette, pixelData };
}

export function decodeImageToPixels(data: PixelImage, width: number, height: number): PixelGrid {
    const pixels: PixelColor[] = data.pixelData.flatMap(i => {
        // Get the color from the palette
        let color = i.paletteIndex[0] === undefined ? undefined : data.palette[i.paletteIndex[0]];
        // Expand the Run Length encoding of the pixel data
        return Array.from({ length: Number(i.count) }, () => color);
    });

    const grid: PixelColor[][] = [];
    for (let y = 0; y < height; y++) {
        grid.push(pixels.slice(y * width, (y + 1) * width));
    }
    return grid;
}

function colorsEqual(a: PixelColor, b: PixelColor): boolean {
    if (a === undefined && b === undefined) {
        return true;
    }
    if (a === undefined || b === undefined) {
        return false;
    }
    return a[0] === b[0] && a[1] === b[1] && a[2] === b[2];
}