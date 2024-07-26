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
    if ("gatherResource" in job) {
        return `Gather ${getResourceIcon(job.gatherResource.resource)} with ${job.gatherResource.workerQuota} worker quota from location ${job.gatherResource.locationId}`;
    } else if ("processResource" in job) {
        return `Process ${getResourceIcon(job.processResource.resource)} with ${job.processResource.workerQuota} worker quota`;
    } else {
        return "NOT IMPLEMENTED JOB: " + toJsonString(job);
    }
};