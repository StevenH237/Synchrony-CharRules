All of these options have a default value that doesn't modify how the game works, so if you don't check the options (Esc menu → Custom rules → Mod settings → Char rules), the mod won't change anything.

All options applied with the mod apply to all players, and "the character" represents all of them.

It's undefined whether these settings change 

# Health options
These settings change how the character's health behaves. Note that health values are all measured in half hearts, with whole hearts displayed for convenience. Additionally, values set to 0 will be replaced by the character's default.

* **Starting health**: The character's starting health. If it's set higher than "Starting max health" (or the character's default), the higher starting health will still apply, but not appear.
* **Starting max health**: The character's starting max health (heart containers).
* **Starting cursed health**: The character's starting cursed health. This is 0 for all vanilla characters, but may be set anyway.
* **Max health limit**: The highest the character's health can go. This is 1 for Aria and Coda, and 20 for all other vanilla characters. The total of max health and cursed health cannot be raised above this during gameplay, but may start higher (though note that attempting to raise it when it's already higher will drop it to the limit).

## Invincibility options
These settings change how invincibility works for the character. This invincibility does not apply to any self-inflicted blood-related damage or to suicide damage (e.g. Tempo's Curse).

* **Enabled**:
  * **No**: The character can't receive any kind of invincibility frames, such as from food or being hit. This excludes shielding.
  * **Yes**: The character can receive invincibility frames. This is the default for all vanilla characters.
  * **Permanent**: The character is permanently invincible.
* **On hit**: The character receives this many beats of invincibility after taking a hit.
* **On level start**: The character receives this many beats of invincibility when the level starts.

# Inventory settings
These settings change the items which players start with or may receive. Note that if any value is set, it *overrides* the character's default. All three of these fields are space-separated lists, or use just a single space to make it an empty list.

* **Starting inventory**: The items with which the character starts. Note that vanilla ND items have IDs in `PascalCase` rather than `snake_case` - for example, the basic dagger is `WeaponDagger` rather than `weapon_dagger`. For mod items, prefix the mod's name, underscore, the item's ID - and you may have to ask the mod's developer what that ID is.
* **Banned components**: For advanced users, you may remove items with given components from the item pool here. Be careful — if you ban your weapon, you can't pick it up if it's thrown!
* **Cursed slots**: Slots that are cursed cannot change the item (or lack thereof) that is present within them. The slot IDs you can use here are "head", "shovel", "feet", "weapon", "body" (armor), "torch", "ring", "action" (consumable items), "spell", "misc" (charms), "bomb", or "hud".

# Rhythm settings
These settings change how the rhythm of the game is played.

* **Fixed-beat mode**: This setting takes its name from the same setting in Cadence of Hyrule, even though the mod's author believes it to be contradictorily named. Enabling this setting *removes* the requirement that the character move to the beat.
* **Beat multiplier**: This setting allows all characters to play to the same speed of beats. 
* **On song end**: For characters whose songs end, this setting lets you change what happens — either they move to the next floor, or they die.

# Groove chain settings
This category contains two sets of settings. Please note, "Groove chain" is synonymous with "Coin multiplier" or "Obsidian damage".

## Groove chain level settings
These settings change how you earn levels of the groove chain.

* **Kills for first level**: How many kills you have to score without breaking combo to move up from 1x to 2x groove chain. All vanilla characters use "1" for this setting.
* **Kills for later levels**: How many kills you have to score without breaking combo to move up further levels of groove chain, besides from 1x to 2x. All vanilla characters use "4" for this setting.
* **Available levels**: How many total levels are available. All vanilla characters use "3" for this setting, and please note that setting this value higher than 3 does not play nicely with Obsidian sprites (though the items will still work as expected).

## Drop damage penalty settings
These settings change the penalty for missed beat (i.e. Aria, Coda).

* **Active**: Whether or not the damage penalty is active.
* **Damage amount**: How much damage missing the beat causes. This need not be lethal damage, it just happens that 1 is lethal for the only characters that get this by default.

# Gold settings
These settings play around with how the character interacts with gold.

* **Starting gold**: Should be self-explanatory.
* **Gold kills on pickup**: Gold kills the player whenever it is picked up. This also enables a couple related behaviors, for example Leprechauns will drop 0 gold instead of 100 when killed, and the Earth spell will clear gold.
* **Minimum gold drops**: All enemies drop at least this much gold when killed, even if they normally drop 0.
* **Free items from shops**: When this setting is enabled, the character may take one item for free from shops.

# Damage countdown
These settings deal with Tempo's Curse.

* **Active**: Whether or not the damage countdown is active.
* **Damage amount**: How much damage hitting 0 on the countdown causes. This need not be lethal damage, although it defaults to such.
* **Countdown time**: How many beats you get between kills. Note that this number is *one higher* than the highest you'll ever see on the timer itself, for example Tempo's default is 17.