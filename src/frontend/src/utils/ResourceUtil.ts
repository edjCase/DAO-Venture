import { Job, ResourceKind } from "../ic-agent/declarations/main";
import { toJsonString } from "./StringUtil";

export let getResourceIcon = (kind: ResourceKind): string => {
    if ("gold" in kind) {
        return "🪙";
    } else if ("wood" in kind) {
        return "🪵";
    } else if ("stone" in kind) {
        return "🪨";
    } else if ("food" in kind) {
        return "🥕";
    } else {
        return `NOT IMPLEMENTED RESOURCE KIND: ${toJsonString(kind)}`;
    }
};


export let buildJobDescription = (job: Job): string => {
    if ("explore" in job) {
        return `Explore location ${job.explore.locationId}`;
    } else {
        return "NOT IMPLEMENTED JOB: " + toJsonString(job);
    }
};