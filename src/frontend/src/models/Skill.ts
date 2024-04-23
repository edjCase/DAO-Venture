import { Skill } from "../ic-agent/declarations/league";
import { toJsonString } from "../utils/StringUtil";

export const skillToText = (skill: Skill) => {
    if ("speed" in skill) {
        return "Speed";
    }
    if ("battingAccuracy" in skill) {
        return "Batting Accuracy";
    }
    if ("battingPower" in skill) {
        return "Batting Power";
    }
    if ("catching" in skill) {
        return "Catching";
    }
    if ("throwingAccuracy" in skill) {
        return "Throwing Accuracy";
    }
    if ("throwingPower" in skill) {
        return "Throwing Power";
    }
    return "NOT IMPLEMENTED: " + toJsonString(skill);
};