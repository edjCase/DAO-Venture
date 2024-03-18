import { Principal } from "@dfinity/principal";

export function toJsonString(obj: any, indent: boolean = true): string {
    let space = indent ? 2 : undefined;
    return JSON.stringify(obj, (_, value: any) => {
        if (typeof value === "bigint" || value instanceof Principal) {
            return value.toString();
        }
        return value;
    }, space);
}

export function toRgbString(color: [number, number, number]): string {
    return `rgb(${color[0]}, ${color[1]}, ${color[2]})`;
}