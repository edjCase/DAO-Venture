<script>
  import CharacterAttributeIcon from "./character/CharacterAttributeIcon.svelte";
  import GameIcon from "./game/GameIcon.svelte";
</script>

<div class="px-4 py-4">
  <div class="space-y-10">
    <section>
      <h2 class="text-4xl font-semibold mb-4 text-primary-500 text-center">
        Game Overview
      </h2>
      <p class="mb-4">
        DAOVenture is a browser-based roguelite game where players navigate
        through challenging scenarios, engage in tactical combat, and make
        impactful decisions that shape their adventure.
      </p>
    </section>

    <section>
      <h2 class="text-2xl font-semibold mb-4 text-primary-500">
        Character Creation
      </h2>
      <div class="space-y-4">
        <div>
          <h3 class="text-xl mb-2 text-primary-500">Race and Class</h3>
          <p>
            Players select a randomly generated combination of race and class.
            Each combination provides:
          </p>
          <ul class="list-disc list-inside mt-2 space-y-2">
            <li>Starting items</li>
            <li>Starting skills (actions)</li>
            <li>Pixel art representation</li>
          </ul>
        </div>
        <div>
          <h3 class="text-xl mb-2 text-primary-500">Attributes</h3>
          <p>
            Characters have four primary attributes that affect what scenario
            choices they have and how likely they are to succeed in that choice,
            they do not affect combat.
          </p>
          <ul class="list-disc list-inside mt-2 space-y-2">
            <li>
              <span class="text-primary-500">Charisma</span>
              <CharacterAttributeIcon value={{ charisma: null }} />: Influences
              social interactions and certain scenario options
            </li>
            <li>
              <span class="text-primary-500">Wisdom</span>
              <CharacterAttributeIcon value={{ wisdom: null }} />: Affects
              decision-making and magical abilities
            </li>
            <li>
              <span class="text-primary-500">Dexterity</span>
              <CharacterAttributeIcon value={{ dexterity: null }} />: Impacts
              agility-based actions and evasion
            </li>
            <li>
              <span class="text-primary-500">Strength</span>
              <CharacterAttributeIcon value={{ strength: null }} />: Determines
              physical power and carrying capacity
            </li>
          </ul>
        </div>
      </div>
    </section>

    <section>
      <h2 class="text-2xl font-semibold mb-4 text-primary-500">
        Gameplay Loop
      </h2>
      <div class="space-y-4">
        <div>
          <h3 class="text-xl mb-2 text-primary-500">Zones</h3>
          <p>
            The game is divided into three themed zones of increasing
            difficulty. Each zone contains various scenarios and encounters.
          </p>
        </div>
        <div>
          <h3 class="text-xl mb-2 text-primary-500">Scenarios</h3>
          <p>
            Scenarios are the core gameplay element where each is a unique set
            of events like:
          </p>
          <ul class="list-disc list-inside mt-2 space-y-2">
            <li>Choice-based events with risk/reward decisions</li>
            <li>Combat encounters with various creatures</li>
            <li>Rewards</li>
          </ul>
          <p class="mt-2">
            Scenario outcomes are influenced by character attributes, player
            choices and randomness.
          </p>
        </div>
      </div>
    </section>

    <section>
      <h2 class="text-2xl font-semibold mb-4 text-primary-500">Weapons</h2>
      <p class="mt-4">
        Weapons can be found, earned through gameplay, or acquired as rewards
        from scenarios. Each character starts with a weapon based on their class
        and can only hold one weapon at a time. Weapons have a fixed number of
        actions can perform in combat (see <span class="text-primary-500"
          >Combat Efftects</span
        >).
      </p>
    </section>

    <section>
      <h2 class="text-2xl font-semibold mb-4 text-primary-500">
        Combat System
      </h2>
      <div class="space-y-4">
        <div>
          <h3 class="text-xl mb-2 text-primary-500">Turn-Based Battles</h3>
          <ul class="list-disc list-inside mt-2 space-y-2">
            <li>
              Players choose one of three action slots each turn: Weapon, Skill,
              or Item. Each slot is randomized each turn, so not all actions
              will be available every turn.
            </li>
            <li>Creatures have randomized actions</li>
          </ul>
        </div>
        <div>
          <h3 class="text-xl mb-2 text-primary-500">Combat Effects</h3>
          <p>Actions in combat can produce various effects:</p>
          <ul class="list-disc list-inside mt-2 space-y-2">
            <li>Damage <GameIcon value="damage" />: Reduce target's health</li>
            <li>
              Heal <GameIcon value="heal" />: Restore health to self or allies
            </li>
            <li>
              Block <GameIcon value="block" />: Provide temporary defense
              against incoming damage
            </li>
            <li>Status Effects: Apply various conditions that affect combat</li>
          </ul>
        </div>
        <div>
          <h3 class="text-xl mb-2 text-primary-500">Status Effects</h3>
          <p>Status effects add depth to combat strategies:</p>
          <ul class="list-disc list-inside mt-2 space-y-2">
            <li>
              Retaliating <GameIcon value="retaliating" />: Deals damage to
              attacker when hit
            </li>
            <li>
              Brittle <GameIcon value="brittle" />: Target gains reduced block
            </li>
            <li>Weak <GameIcon value="weak" />: Deals reduced damage</li>
            <li>
              Vulnerable <GameIcon value="vulnerable" />: Takes increased damage
            </li>
            <li>
              Necrotic <GameIcon value="necrotic" />: Reduces healing
            </li>
            <li>Stunned <GameIcon value="stunned" />: Skips next turn</li>
          </ul>
        </div>
        <div>
          <h3 class="text-xl mb-2 text-primary-500">Other</h3>
          <ul class="list-disc list-inside mt-2 space-y-2">
            <li>
              Periodic <GameIcon value="periodic" />: Applies damage, heal or
              block over time
            </li>
            <li>
              Self <GameIcon value="self" />: Applies effect to self
            </li>
          </ul>
        </div>
      </div>
    </section>

    <section>
      <h2 class="text-2xl font-semibold mb-4 text-primary-500">
        Progression and Achievements
      </h2>
      <div class="space-y-4">
        <div>
          <h3 class="text-xl mb-2 text-primary-500">Character Progress</h3>
          <p>
            While each run resets character progress, players can unlock
            permanent achievements that persist between runs, adding
            replayability and long-term goals.
          </p>
        </div>
        <div>
          <h3 class="text-xl mb-2 text-primary-500">Unlockables</h3>
          <p>
            Various game elements can be unlocked through achievements or
            specific requirements:
          </p>
          <ul class="list-disc list-inside mt-2 space-y-2">
            <li>New races and classes</li>
            <li>Weapons and items</li>
            <li>Additional scenarios and creatures</li>
            <li>Access to new zones</li>
          </ul>
        </div>
      </div>
    </section>

    <section>
      <h2 class="text-2xl font-semibold mb-4 text-primary-500">
        Winning the Game
      </h2>
      <p>Winning just requires the player to survive until the end.</p>
      <p>
        The player can also choose to surrender at any time, which will end the
        current run and reset character progress.
      </p>
      <p>Players will not unlock achievements unless they complete the runs</p>
    </section>
  </div>
</div>
