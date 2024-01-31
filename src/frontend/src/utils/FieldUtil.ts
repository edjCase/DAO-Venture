
export function getFontSize(name: string): number {
    const baseFontSize = 3;
    const limit = 7;
    const reductionPerExtraCharacter = 0.2;

    if (name.length > limit) {
        const extraCharacters = name.length - limit;
        return 2.5 - (extraCharacters * reductionPerExtraCharacter);
    }

    return baseFontSize;
};