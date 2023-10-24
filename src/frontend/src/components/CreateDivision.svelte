<script lang="ts">
  import { divisionStore } from "../stores/DivisionStore";
  import { leagueAgentFactory } from "../ic-agent/League";

  let name: string;
  let dayOfWeekValue: string;
  let createDivision = function () {
    let dayOfWeek;
    switch (dayOfWeekValue) {
      case "Sunday":
        dayOfWeek = { sunday: null };
        break;
      case "Monday":
        dayOfWeek = { monday: null };
        break;
      case "Tuesday":
        dayOfWeek = { tuesday: null };
        break;
      case "Wednesday":
        dayOfWeek = { wednesday: null };
        break;
      case "Thursday":
        dayOfWeek = { thursday: null };
        break;
      case "Friday":
        dayOfWeek = { friday: null };
        break;
      case "Saturday":
        dayOfWeek = { saturday: null };
        break;
      default:
        throw "Invalid day of week: " + dayOfWeekValue;
    }
    let timeOfDay = { hour: BigInt(12), minute: BigInt(0) }; // TODO
    let timeZoneOffsetSeconds = 0; // TODO
    leagueAgentFactory()
      .createDivision({ name, dayOfWeek, timeOfDay, timeZoneOffsetSeconds })
      .then(() => {
        divisionStore.refetch();
      })
      .catch((err) => {
        window.alert("Failed to make team: " + err);
      });
  };
</script>

<div>
  <label for="team-name">Name</label>
  <input type="text" id="team-name" bind:value={name} />
</div>
<div>
  <label for="day-of-week">Day of Week</label>
  <select id="day-of-week" bind:value={dayOfWeekValue}>
    <option value="Sunday">Sunday</option>
    <option value="Monday">Monday</option>
    <option value="Tuesday">Tuesday</option>
    <option value="Wednesday">Wednesday</option>
    <option value="Thursday">Thursday</option>
    <option value="Friday">Friday</option>
    <option value="Saturday">Saturday</option>
  </select>
</div>
<button on:click={createDivision}>Create Division</button>
