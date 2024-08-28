
type Rgb = { red: number; green: number; blue: number };

export function encodeRLEBase64(grid: Rgb[][]): string {
    const rle: number[] = [];
    let prevColor: Rgb | undefined;
    let count = 0;

    grid.flat().forEach((color) => {
        if (prevColor === undefined || !colorsEqual(color, prevColor)) {
            if (prevColor !== undefined) {
                rle.push(count, prevColor.red, prevColor.green, prevColor.blue);
            }
            prevColor = color;
            count = 1;
        } else count++;
    });
    if (prevColor) {
        rle.push(count, prevColor.red, prevColor.green, prevColor.blue);
    }
    console.log(rle);
    return btoa(
        unescape(encodeURIComponent(String.fromCharCode.apply(null, rle))) // TODO??
    );
}

export function decodeBase64RLE(base64: string): Rgb[][] {
    const binaryString = decodeURIComponent(escape(atob(base64)));
    const rle = new Uint8Array(binaryString.split('').map(char => char.charCodeAt(0)));

    const pixels: Rgb[] = [];
    for (let i = 0; i < rle.length; i += 4) {
        const count = rle[i];
        const color: Rgb = { red: rle[i + 1], green: rle[i + 2], blue: rle[i + 3] };
        pixels.push(...Array(count).fill(color));
    }

    // Assuming 16x16 grid, adjust if your grid size is different
    const grid: Rgb[][] = [];
    for (let i = 0; i < 16; i++) {
        grid.push(pixels.slice(i * 16, (i + 1) * 16));
    }

    return grid;
}

function colorsEqual(a: Rgb, b: Rgb): boolean {
    return a.red === b.red && a.green === b.green && a.blue === b.blue;
}