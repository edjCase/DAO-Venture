export function getOptValueOrUndefined<T>(value: [] | [T]): T | undefined {
    if (value.length === 0) {
        return undefined;
    }
    return value[0];
}