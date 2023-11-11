export function nanosecondsToDate(nanoseconds: bigint): Date {
    const milliseconds = Number(nanoseconds / BigInt(1000000));
    return new Date(milliseconds);
};

export function dateToNanoseconds(date: Date): bigint {
    return BigInt(date.getTime()) * BigInt(1000000);
};

export function nanosecondsToRelativeWeekString(time: bigint) {
    let date = nanosecondsToDate(time);
    const oneWeek = 1000 * 60 * 60 * 24 * 7;
    const now = new Date();
    const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    const target = new Date(
        date.getFullYear(),
        date.getMonth(),
        date.getDate()
    );

    const diffInTime = target.getTime() - today.getTime();
    const diffInWeeks = Math.round(diffInTime / oneWeek);

    switch (diffInWeeks) {
        case 0:
            return "This Week";
        case 1:
            return "Next Week";
        case -1:
            return "Last Week";
        default:
            return `${Math.abs(diffInWeeks)} Weeks ${diffInWeeks > 0 ? "Ahead" : "Ago"
                }`;
    }
};