import { FieldPosition } from "../ic-agent/declarations/players";
import { toJsonString } from "../utils/JsonUtil";

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

export function mapPosition(position: FieldPositionEnum): FieldPosition {
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
export function unMapPosition(position: FieldPosition): FieldPositionEnum {
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
