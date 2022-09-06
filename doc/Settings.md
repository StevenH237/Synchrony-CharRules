Character Rules doesn't change anything by default. You have to modify settings under Custom Rules for this mod to have any effect. The settings are documented below.

Advanced settings are listed on this page. If you have not enabled "Show advanced settings" in the main Custom Rules menu, non-bolded options do not appear.

A "quatristate" has four possible settings:
* **Default**: This rule is unchanged - characters that normally have it have it, and characters that don't don't. Which settings are enabled for which characters by default is listed on [this page](Defaults.md).
* **Enable**: This rule is enabled for all characters.
* **Disable**: This rule is disabled for all characters.
* **Randomize**: This rule is applied randomly to characters. Note that it is applied the same way to all players of the same character.

# Character-specific rules
**Tips:** You can use the left-right arrow keys on section headers to jump between the sections!

**Note:** Rules relating to items aren't shown in here; go to the [Inventory](#inventory) section to set those.

## Aria's rules
* **Damage on missed beat**: (Quatristate) If enabled, the character takes half a heart of damage from a missed beat.
* Amount of damage: The amount of damage caused by a missed beat.
* Type of damage: The type of damage caused by a missed beat.
* Bypass sarcophagus: (Quatristate) If enabled, exits are unlocked after the miniboss is killed even on floors with a sarcophagus.

## Dorian's rules
* **Boots of painful leaping**: (Quatristate) If enabled, the character takes half a heart of damage when moving with disabled Boots of Leaping/Lunging.
* Amount of damage: The amount of damage caused by a short step.
* Type of damage: The type of damage caused by a short step.

## Eli's rules
* **Empty shop walls**: (Quatristate) If enabled, shop walls do **not** drop gold when destroyed.

## Monk's rules
* **Vow of poverty**: (Quatristate) If enabled, picking up gold kills the character. (This also bans the Ring of Gold for this character.)
* **Free items from shops**: (Quatristate) If enabled, the character can get one item from each shop for free.
* **Collect gold on stairs**: (Quatristate) If enabled, the character automatically collects all gold on the floor when going down the stairs.
* **All enemies drop gold**: (Quatristate) If enabled, all enemies killed by this character drop by at least one gold, including mushrooms, cauldrons, and boss enemies.

## Dove's rules
* **Teleporting bombs**: (Quatristate) If enabled, this character's bombs teleport enemies instead of damaging them.
* **Bypass miniboss**: (Quatristate) If enabled, the exit stairs are automatically unlocked without killing the miniboss.

## Bolt's rules
* **Tempo multiplier**: If set, all characters must play at this tempo multiplier, regardless of whether or not they're Bolt. (This can be up to 20.)

## Bard's rules
* **Ignore rhythm**: (Quatristate) If enabled, the character does not have to move to the beat.

## Mary's rules
*Only with Amplified DLC installed and enabled.*

* **Protect a sheep**: (Quatristate) If enabled, the character is followed by a sheep.

## Tempo's rules
*Only with Amplified DLC installed and enabled.*

* **Increase damage**: (Quatristate) If enabled, this character has inherent damage increase.
* Damage increase amount: The amount by which to increase damage. Defaults to 999.
* **Kill timer**: (Quatristate) If enabled, this character must kill every 17 beats or they die.
* Amount of damage: The amount of damage taken when the timer expires.
* Type of damage: The type of damage taken when the timer expires.

# Unspecific rules
*Advanced settings view only.*

* Allowed actions: Which actions can a character take?
  * Standard movement: The default for most characters.
  * Diamond movement: The default for Diamond (Amplified DLC). Klarinetta (Synchrony DLC) also uses this.
  * 8-way + spells: Like Diamond, but the spells are usable instead of item/bomb.
  * Skew: Left and right movement move diagonally instead.

# Inventory

## Items
* **Clear inventory**: If checked, all characters will have their inventory cleared before items are added below.
* **Give items**: Items in this list are given to all players. If they replace default items from the character, those items are dropped (unless Clear is checked).

## Bans
All of these are quatristates. If enabled, the affected items cannot be generated or picked up by the character. These should be self-explanatory.

## Cursed inventory slots
*Advanced settings view only.*

All of these are quatristates. When a setting is enabled, that slot is cursed, preventing the item in that slot from being changed whatsoever.

# Health settings
* **Use these settings**: If checked, all characters have their starting health as determined by this page. If not checked, nothing else on this page has any effect.
* **Starting health**: The number of filled heart containers the characters start with.
* **Health containers**: The number of total (filled + empty) heart containers the characters start with.
* Cursed health: *Amplified DLC required.* The number of cursed heart containers the characters start with.
* **Health limit**: The maximum number of heart containers the characters can have.

# Map generation settings
*Advanced settings view only. Note: Settings set to random are applied consistently to all characters, giving them a 50% chance to affect each run regardless of party size.*

* Skip gold in vaults: Gold in walls and vaults does not spawn.
* Reverse zone order: Fight through zones 5 to 1 (4 to 1 without Amplified).
* Skip boss fights: Skip boss fights at the end of each zone.
* Smaller shops: Remove one item from every main shop.

# Tweaks
*Advanced settings view only.*

* Golden lute damages golden lute: If enabled, the Golden Lute (item) causes damage to the Golden Lute (boss), so that Melody can take part in Aria's story boss.