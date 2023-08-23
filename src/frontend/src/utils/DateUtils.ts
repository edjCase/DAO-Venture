export function nanosecondsToDate(nanoseconds: bigint): Date {
    const milliseconds = Number(nanoseconds / BigInt(1000000));
    return new Date(milliseconds);
};

export function dateToNanoseconds(date: Date): bigint {
    return BigInt(date.getTime()) * BigInt(1000000);
};