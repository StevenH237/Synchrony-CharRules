# `necro.game.system.Action`
## `Action.Direction`
| Value | Name         | Rotation   |
| ----: | :----------- | :--------- |
|     0 | `NONE`       |            |
|     1 | `RIGHT`      | `IDENTITY` |
|     2 | `UP_RIGHT`   | `CCW_45`   |
|     3 | `UP`         | `CCW_90`   |
|     4 | `UP_LEFT`    | `CCW_135`  |
|     5 | `LEFT`       | `MIRROR`   |
|     6 | `DOWN_LEFT`  | `CW_135`   |
|     7 | `DOWN`       | `CW_90`    |
|     8 | `DOWN_RIGHT` | `CW_45`    |

## `Action.Special`
| Value | Name      | Notes            |
| ----: | :-------- | :--------------- |
|     0 | `IDLE`    |                  |
|     9 | `ITEM 1`  |                  |
|    10 | `ITEM 2`  | also Holster     |
|    11 | `BOMB`    |                  |
|    12 | `THROW`   | also Toggle Item |
|    13 | `SPELL 1` |                  |
|    14 | `SPELL 2` |                  |


# `necro.game.character.Attack`
## `Attack.Flag`
|      Value | Flag          | Also flag   |
| ---------: | :------------ | :---------- |
|         -1 |               | `ALL`       |
|          0 |               | `NONE`      |
|          1 | `DIRECT`      | `DEFAULT`   |
|          2 | `INDIRECT`    | `CHARACTER` |
|          4 | `PROVOKE`     |             |
|          8 | `PHASING`     |             |
|         16 | `EXPLOSIVE`   |             |
|         32 | `UNDEAD`      |             |
|         64 | `TRAP`        |             |
|        128 | `KICK`        |             |
|        256 | `EARTHQUAKE`  |             |
|        512 | `PAIN`        |             |
| 1073741824 | `IGNORE_TEAM` |             |


# `necro.game.system.Damage`
## `Damage.Flag`
| Value | Flag                    |
| ----: | :---------------------- |
|     1 | `BYPASS_ARMOR`          |
|     2 | `BYPASS_INVINCIBILITY`  |
|     4 | `BYPASS_DEATH_TRIGGERS` |
|     8 | `STRENGTH_BASED`        |
|    16 | `EXPLOSIVE`             |
|    32 | `PARRYABLE`             |
|    64 | `SELF_DAMAGE`           |
|   128 | `IGNORE_GRABBED`        |
|   256 | `TRAP`                  |
|   512 | `TERRAIN`               |
|  1024 | `VOICE_SQUISH`          |
|  2048 | `GOLDEN_LUTE`           |
|  4096 | `EARTHQUAKE`            |
|  8192 | `IGNORE_SHEEP`          |
| 16384 | `BYPASS_IMMUNITY`       |
| 32768 | `ELECTRIC`              |

## `Damage.Type`
| Value | Type          | Flags                                                                                                             |
| ----: | :------------ | :---------------------------------------------------------------------------------------------------------------- |
|     0 | `SPECIAL`     |                                                                                                                   |
|     1 | `PIERCING`    | `BYPASS_ARMOR`                                                                                                    |
|     3 | `PHASING`     | `BYPASS_ARMOR`<br />`BYPASS_INVINCIBILITY`                                                                        |
|    32 | `INDIRECT`    | `PARRYABLE`                                                                                                       |
|    40 | `PHYSICAL`    | `PARRYABLE`<br />`STRENGTH_BASED`                                                                                 |
|    65 | `SELF_DAMAGE` | `BYPASS_ARMOR`<br />`SELF_DAMAGE`                                                                                 |
|    67 | `BLOOD`       | `BYPASS_ARMOR`<br />`BYPASS_INVINCIBILITY`<br />`SELF_DAMAGE`                                                     |
|   128 | `MAGIC`       | `IGNORE_GRABBED`                                                                                                  |
|   144 | `EXPLOSIVE`   | `EXPLOSIVE`<br />`IGNORE_GRABBED`                                                                                 |
|   256 | `TRAP`        | `TRAP`                                                                                                            |
|  1024 | `SQUISHY`     | `VOICE_SQUISH`                                                                                                    |
|  4103 | `EARTHQUAKE`  | `BYPASS_ARMOR`<br />`BYPASS_INVINCIBILITY`<br />`BYPASS_DEATH_TRIGGERS`<br />`EARTHQUAKE`                         |
| 16455 | `SUICIDE`     | `BYPASS_ARMOR`<br />`BYPASS_INVINCIBILITY`<br />`BYPASS_DEATH_TRIGGERS`<br />`SELF_DAMAGE`<br />`BYPASS_IMMUNITY` |



# `necro.game.tile.LevelExit`
## `LevelExit.StairLock`
| Value | Type          |
| ----: | :------------ |
|     1 | `SARCOPHAGUS` |
|     2 | `MINIBOSS`    |