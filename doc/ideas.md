# Component `attackable` (AttackComponents)

## `attackable.flags`: [Attack.Flag](relevant-flags.md) bitmask
Which types of damage the character can take.

All characters have Direct (1), Indirect (2), and Pain (512). Except for NocturnaBat, they also have Trap (64).


# Component `bypassStairLock` (DescentComponents)

## `bypassStairLock.flags`: LevelExit.StairLock bitmask
The flags are as follows.

* 1 † Ignore sarcophagus, if applicable
* 2 ‡ Ignore miniboss


# Component `cursedHealth` (HealthComponents)

## `cursedHealth.health`: int
Set this to add cursed hearts to the health bar.


# Component `damageCountdown` (CharacterComponents)

## `damageCountdown.damage`: int
The actual damage done to the character.

## `damageCountdown.countdownReset`: int
The value to which the countdown should be reset.

## `damageCountdown.type`: Damage.Type bitmask
The type of damage which should be inflicted.

* 0 Special
* 1 Piercing
* 3 Phasing
* 32 Indirect
* 40 Physical
* 65 Self-damage
* 


# Component `damageIncrease` (AttackComponents)
`nil` for most characters, except Tempo (`{damage=999}`)


# Component `dwarfism`
`{}` for most characters (`false` for NocturnaBat), but I should look into it...

Also look into other Dwarfism-related components


# Component `forceObjectVision`
`nil` for most characters, except NocturnaBat and Tempo (`{component="visibleByTelepathy"}`)

Also look into `forceNonSilhouetteVision`


# Component `freezable`
`{}` for all characters, but I should look into it...

Also look into `freezableThawOnHit` and other Freeze-related components


# Component `gigantism`
`{}` for all characters, but I should look into it...

Also look into other Gigantism-related components


# Component `goldHater`
`nil` for most characters, except Monk and Coda (`{}`).


# Component `health`
Has properties `health` and `maxHealth` which are self-explanatory. They're measured in half-hearts.

Worth noting that if the player starts with a Ring of Peace, `maxHealth` is increased by two *before* `health` is applied.


# Component `healthLimit`
Has property `limit`. Limits `health.maxHealth`.


# Component `hudOpacity`
`nil` for most characters, except NocturnaBat. Might be worth looking into for "hidden hud" runs.


# Component `initialInventory`
Varied, but could be used to control starting inventories with a simpler version of "ControlledStartingInventory" mod.


# Component `inventoryBannedItems`
This is the item ban controller. Could be fun to make options for.


# Component `inventoryCursedSlots`
This is the slot curse controller. Could be fun to make options for.


# Component `invincibility`
This one really attracts me by its name. It's just `{}` for all characters. I'm *intrigued*. Same for the other components.


# Component `itemCollector`
This is `{}` for all characters, but what if I look into it...


# Component `itemUser`
This is `{}` for all characters *except NocturnaBat (`false`)*.


# Component `knockbackable` (AttackComponents)
This is `{beatDelay=0}` for all characters. I wonder what happens if I change that.


# Component `maxHealthRounding`
This is `{roundDownThreshold=1, roundingFactor=2}` for all characters. I wonder what happens if I change that.


# Component `rhythmIgnored`
Another big one, this is `nil` for most characters except Bard (`{}`).


# Component `rhythmIgnoredTemporarily`
This is `{}` for most characters except Bard (`false`).


# Component `rhythmSkipEveryNth`
This is `{}` for all characters. I wonder what happens if I change that.


# Component `rhythmSubdivision`
This is `nil` for most characters, except Coda and Bolt (`{factor=2}`). I wonder what happens if I change that.


# Component `riskDamage`
This is `{}` for all characters. I wonder what happens if I change that.


# Component `shoplifter`
This is `nil` for most characters, but not Coda, Monk, or Dove (`{}`).


# Component `sinkable`
This is `{unsinkOnForcedMove}` for most characters, but not NocturnaBat (`false`). I could change that...


# Component `slideOnSlipperyTile`
This is `{}` for most characters, but not NocturnaBat (`false`). I could change that...


# Component `songEndCast`
This is `{spell="SpellcastSongEnd"}` for most characters, but not Dove (`{spell="SpellcastSuicide"}`). Let's change this too...


# Component `songEndDescent`
This is `nil` for most characters, but not Bard (`false`). I could change that too...


# Component `spawnAppiritions`
This is `nil` for most characters, but not NocturnaBat or Tempo (`{component="visibleByTelepathy"}`).


# Component `stealth`
This is `{}` for all characters.


# Component `team` (AttackComponents)
This is `{id=1}` for all characters.


# Component `teleportingBombs`
This is `nil` for most characters, but `{}` for Dove.


# Component `tileDwarfismReceiver`
This is `{}` for most characters, but `false` for NocturnaBat.


# Component `tileIdleDamageReceiver`
This is `{}` for most characters, but `false` for NocturnaBat.


# Component `transformable`
This is `nil` for most characters, except:

* Nocturna: `{targetType="NocturnaBat"}`
* NocturnaBat: `{bloodCost=1, targetType="Nocturna"}`


# Component `wallDropSuppressor`
This is `nil` for most characters, but `{}` for Eli.


# Component `weapon`
This is `nil` for most characters, except:

* Eli: `{damage=0, damageType=32}`
* NocturnaBat: `{damage=4}`


# Component `weaponKnockback`
This is `nil` for most characters, but `{distance=3}` for Eli.


# Component `weaponPattern`
This is `nil` for most characters, except:

* Eli: `{pattern={collisionMask=8, tiles{{attackFlags=1073741952, offset={1, 0}, targetFlags=1073741952}}}}`
* NocturnaBat: `{pattern={swipe="dagger", tiles={{attackFlags=1, offset={1, 0}, swipe="dagger", targetFlags=1}}}}`


# Component `wired`
This is `{}` for most characters, but `false` for NocturnaBat.
