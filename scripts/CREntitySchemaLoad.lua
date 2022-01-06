local Action          = require "necro.game.system.Action"
local Event           = require "necro.event.Event"
local ItemBan         = require "necro.game.item.ItemBan"
local LevelExit       = require "necro.game.tile.LevelExit"
local SettingsStorage = require "necro.config.SettingsStorage"

local CRSettings = require "CharRules.CRSettings"
local CREnum     = require "CharRules.CREnum"

local CSILoaded = pcall(require, "ControlledStartingInventory.CSISettings")

local PowerSettings = require "PowerSettings.PowerSettings"

------------
-- EVENTS --
--#region---

Event.entitySchemaLoadEntity.add("charRulesComponents", {order="overrides"}, function(ev)
  if not ev.entity.playableCharacter then return end

  local entity = ev.entity

  entity.inventoryBannedItems = entity.inventoryBannedItems or {components={}}
  entity.inventoryBannedItems.components = entity.inventoryBannedItems.components or {}

  entity.bypassStairLock = entity.bypassStairLock or {level=0}
  entity.bypassStairLock.level = entity.bypassStairLock.level or LevelExit.StairLock.MINIBOSS

  --#region Aria's rules
  if CRSettings.get("characters.missedBeat") == CREnum.Tristate.YES then
    entity.grooveChainInflictDamageOnDrop = entity.grooveChainInflictDamageOnDrop or {}
    entity.grooveChainInflictDamageOnDrop.active = true

    entity.grooveChainInflictDamageOnDrop.type = CRSettings.get("characters.missedBeatType")

    local dmg = CRSettings.get("characters.missedBeatDamage")
    if dmg > 0 then
      entity.grooveChainInflictDamageOnDrop.damage = dmg
    end
  elseif CRSettings.get("characters.missedBeat") == CREnum.Tristate.NO then
    entity.grooveChainInflictDamageOnDrop = false
  end

  if CRSettings.get("characters.bypassSarcophagus") == CREnum.Tristate.YES then
    entity.bypassStairLock = entity.bypassStairLock or {level=0}
    entity.bypassStairLock.level = bit.bor(entity.bypassStairLock.level, LevelExit.StairLock.SARCOPHAGUS)
  elseif CRSettings.get("characters.bypassSarcophagus") == CREnum.Tristate.NO then
    entity.bypassStairLock = entity.bypassStairLock or {level=0}
    entity.bypassStairLock.level = bit.band(entity.bypassStairLock.level, bit.bnot(LevelExit.StairLock.SARCOPHAGUS))
  end
  --#endregion

  --#region Dorian's Rules
  if CRSettings.get("characters.cursedBoots") == CREnum.Tristate.YES then
    entity.takeDamageOnUntoggledMovement = entity.takeDamageOnUntoggledMovement or {}

    entity.takeDamageOnUntoggledMovement.type = CRSettings.get("characters.cursedBootsType")

    local dmg = CRSettings.get("characters.cursedBootsDamage")
    if dmg > 0 then
      entity.takeDamageOnUntoggledMovement.damage = dmg
    end
  elseif CRSettings.get("characters.cursedBoots") == CREnum.Tristate.NO then
    entity.takeDamageOnUntoggledMovement = false
  end
  --#endregion

  --#region Eli's Rules
  if CRSettings.get("characters.eliWalls") == CREnum.Tristate.YES then
    entity.wallDropSuppressor = entity.wallDropSuppressor or {}
  elseif CRSettings.get("characters.eliWalls") == CREnum.Tristate.NO then
    entity.wallDropSuppressor = false
  end
  --#endregion

  --#region Monk's Rules
  if CRSettings.get("characters.poverty") == CREnum.Tristate.YES then
    entity.inventoryBannedItems.components.itemCurrency = ItemBan.Flag.PICKUP_DEATH
    entity.inventoryBannedItems.components.itemBanPoverty = ItemBan.Flag.GENERATION
    entity.goldHater = entity.goldHater or {}
  elseif CRSettings.get("characters.poverty") == CREnum.Tristate.NO then
    entity.inventoryBannedItems.components.itemCurrency = 0
    entity.inventoryBannedItems.components.itemBanPoverty = 0
    entity.goldHater = false
  end

  if CRSettings.get("characters.shoplifter") == CREnum.Tristate.YES then
    entity.shoplifter = entity.shoplifter or {}
  elseif CRSettings.get("characters.shoplifter") == CREnum.Tristate.NO then
    entity.shoplifter = false
  end

  if CRSettings.get("characters.descentCollect") == CREnum.Tristate.YES then
    entity.descentCollectCurrency = entity.descentCollectCurrency or {}
  elseif CRSettings.get("characters.descentCollect") == CREnum.Tristate.NO then
    entity.descentCollectCurrency = false
  end

  if CRSettings.get("characters.enemyGold") == CREnum.Tristate.YES then
    entity.minimumCurrencyDrop = entity.minimumCurrencyDrop or {minimum=1}
  elseif CRSettings.get("characters.enemyGold") == CREnum.Tristate.NO then
    entity.minimumCurrencyDrop = false
  end
  --#endregion

  --#region Dove's rules
  if CRSettings.get("characters.teleportingBombs") == CREnum.Tristate.YES then
    entity.teleportingBombs = entity.teleportingBombs or {}
  elseif CRSettings.get("characters.teleportingBombs") == CREnum.Tristate.NO then
    entity.teleportingBombs = false
  end

  if CRSettings.get("characters.bypassMiniboss") == CREnum.Tristate.YES then
    entity.bypassStairLock = entity.bypassStairLock or {level=0}
    entity.bypassStairLock.level = bit.bor(entity.bypassStairLock.level, LevelExit.StairLock.MINIBOSS)
  elseif CRSettings.get("characters.bypassMiniboss") == CREnum.Tristate.NO then
    entity.bypassStairLock = entity.bypassStairLock or {level=0}
    entity.bypassStairLock.level = bit.band(entity.bypassStairLock.level, bit.bnot(LevelExit.StairLock.MINIBOSS))
  end
  --#endregion

  --#region Bolt's settings
  if CRSettings.get("characters.doubleTime") == CREnum.Tristate.YES then
    entity.rhythmSubdivision = entity.rhythmSubdivision or {}
    entity.rhythmSubdivision.factor = 2
  elseif CRSettings.get("characters.doubleTime") == CREnum.Tristate.NO then
    entity.rhythmSubdivision = false
  end

  if CRSettings.get("characters.customTempo") > 1 then
    entity.rhythmSubdivision = entity.rhythmSubdivision or {}
    entity.rhythmSubdivision.factor = CRSettings.get("characters.customTempo")
  elseif CRSettings.get("characters.customTempo") == 1 then
    entity.rhythmSubdivision = false
  end
  --#endregion

  --#region Bard's settings
  if CRSettings.get("characters.noBeats") == CREnum.Tristate.YES then
    entity.rhythmIgnored = entity.rhythmIgnored or {}
    entity.rhythmIgnoredTemporarily = false
    entity.inventoryBannedItems.components.consumableIgnoreRhythmTemporarily = ItemBan.Type.GENERATION
  elseif CRSettings.get("characters.noBeats") == CREnum.Tristate.NO then
    entity.rhythmIgnored = false
    entity.rhythmIgnoredTemporarily = entity.rhythmIgnoredTemporarily or {}
    entity.inventoryBannedItems.components.consumableIgnoreRhythmTemporarily = 0
  end
  --#endregion

  --#region Mary's settings
  if CRSettings.get("characters.marv") == CREnum.Tristate.YES then
    entity.characterWithFollower = {followerType = "Marv"}
  elseif CRSettings.get("characters.marv") == CREnum.Tristate.NO then
    if entity.characterWithFollower and entity.characterWithFollower.followerType == "Marv" then
      entity.characterWithFollower = false
    end
  end
  --#endregion

  --#region Tempo's settings
  if CRSettings.get("characters.damageUp") == CREnum.Tristate.YES then
    entity.damageIncrease = entity.damageIncrease or {damage=999}
    if CRSettings.get("characters.damageUpAmount") > 0 then
      entity.damageIncrease.damage = CRSettings.get("characters.damageUpAmount")
    end
  elseif CRSettings.get("characters.damageUp") == CREnum.Tristate.NO then
    entity.damageIncrease = {}
  end

  if CRSettings.get("characters.killTimer") == CREnum.Tristate.YES then
    entity.damageCountdown = entity.damageCountdown or {}
    entity.damageCountdown.countdownReset = entity.damageCountdown.countdownReset or 17
    entity.damageCountdown.damage = entity.damageCountdown.damage or 999
    entity.damageCountdown.killerName = entity.damageCountdown.killerName or "Tempo's Curse"
    if CRSettings.get("characters.killTimerDamage") > 0 then
      entity.damageCountdown.damage = CRSettings.get("characters.killTimerDamage")
    end
    entity.damageCountdown.type = CRSettings.get("characters.killTimerType")
      entity.damageCountdownFlyaways = entity.damageCountdownFlyaways or {
      texts = { "0", "1", "2", "3", "4", "5",
        [11] = "10"
      }
    }
  end
  --#endregion
end)

--#endregion