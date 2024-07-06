import { FieldPosition } from "../ic-agent/declarations/main";
import { toJsonString } from "../utils/StringUtil";

export enum FieldPositionEnum {
    Pitcher = "Pitcher",
    FirstBase = "First Base",
    SecondBase = "Second Base",
    ThirdBase = "Third Base",
    ShortStop = "Shortstop",
    LeftField = "Left Field",
    CenterField = "Center Field",
    RightField = "Right Field",
}

export function fromEnum(position: FieldPositionEnum): FieldPosition {
    switch (position) {
        case FieldPositionEnum.Pitcher:
            return { pitcher: null };
        case FieldPositionEnum.FirstBase:
            return { firstBase: null };
        case FieldPositionEnum.SecondBase:
            return { secondBase: null };
        case FieldPositionEnum.ThirdBase:
            return { thirdBase: null };
        case FieldPositionEnum.ShortStop:
            return { shortStop: null };
        case FieldPositionEnum.LeftField:
            return { leftField: null };
        case FieldPositionEnum.CenterField:
            return { centerField: null };
        case FieldPositionEnum.RightField:
            return { rightField: null };
        default:
            throw "Invalid position: " + position;
    }
};
export function toEnum(position: FieldPosition): FieldPositionEnum {
    if ('pitcher' in position) {
        return FieldPositionEnum.Pitcher;
    }
    if ('firstBase' in position) {
        return FieldPositionEnum.FirstBase;
    }
    if ('secondBase' in position) {
        return FieldPositionEnum.SecondBase;
    }
    if ('thirdBase' in position) {
        return FieldPositionEnum.ThirdBase;
    }
    if ('shortStop' in position) {
        return FieldPositionEnum.ShortStop;
    }
    if ('leftField' in position) {
        return FieldPositionEnum.LeftField;
    }
    if ('centerField' in position) {
        return FieldPositionEnum.CenterField;
    }
    if ('rightField' in position) {
        return FieldPositionEnum.RightField;
    }

    throw new Error("Invalid position: " + toJsonString(position));
}


export const fieldPositionToString = (position: FieldPosition): string => {
    if ("pitcher" in position) {
        return "Pitcher";
    } else if ("firstBase" in position) {
        return "1st Base";
    } else if ("secondBase" in position) {
        return "2nd Base";
    } else if ("thirdBase" in position) {
        return "3rd Base";
    } else if ("shortStop" in position) {
        return "Short Stop";
    } else if ("leftField" in position) {
        return "Left Field";
    } else if ("centerField" in position) {
        return "Center Field";
    } else if ("rightField" in position) {
        return "Right Field";
    }
    return "Unknown";
};

