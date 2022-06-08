local Action          = require "necro.game.system.Action"
local Event           = require "necro.event.Event"
local ItemBan         = require "necro.game.item.ItemBan"
local LevelExit       = require "necro.game.tile.LevelExit"
local RNG             = require "necro.game.system.RNG"
local SettingsStorage = require "necro.config.SettingsStorage"

local CRSettings = require "CharRules.CRSettings"
local CREnum     = require "CharRules.CREnum"
local CRSchema   = require "CharRules.CROldEntitySchema"

local CSILoaded = pcall(require, "ControlledStartingInventory.CSISettings")

local PowerSettings = require "PowerSettings.PowerSettings"

------------------
-- RNG CHANNELS --
--#region---------

local RNGChannel = {}

--#endregion

---------------
-- FUNCTIONS --
--#region------

local function getTristate(quat)
  -- We're gonna use an rng call no matter what, so that the randomization isn't determined by which settings are set to random.
  local randomTristate = RNG.choice({ CREnum.Tristate.NO, CREnum.Tristate.DEFAULT, CREnum.Tristate.YES }, RNGChannel)

  if quat == CREnum.Quatristate.NO then
    return CREnum.Tristate.NO
  elseif quat == CREnum.Quatristate.DEFAULT then
    return CREnum.Tristate.DEFAULT
  elseif quat == CREnum.Quatristate.YES then
    return CREnum.Tristate.YES
  else
    return randomTristate
  end
end

local function getTristateSetting(setting)
  return getTristate(CRSettings.get(setting))
end

--#endregion

------------
-- EVENTS --
--#region---

Event.entitySchemaGenerate.add("checks", { order = "components", sequence = -1 }, function()
  print("New entity schema generation...")
  RNGChannel = {
    state1 = 237,
    state2 = 794824,
    state3 = CRSettings.get("random")
  }
end)

Event.entitySchemaLoadEntity.add("charRulesComponents", { order = "overrides", sequence = 2 }, function(ev)
  if not ev.entity.playableCharacter then return end

  local entity = ev.entity

  entity.inventoryBannedItems = entity.inventoryBannedItems or { components = {} }
  entity.inventoryBannedItems.components = entity.inventoryBannedItems.components or {}

  entity.bypassStairLock = entity.bypassStairLock or { level = 0 }
  entity.bypassStairLock.level = entity.bypassStairLock.level or LevelExit.StairLock.MINIBOSS

  --#region Character-specific rules
  --#region Aria's rules
  local rule = getTristateSetting("characters.missedBeat")
  print("Missed beat rule for " .. entity.name .. ": " .. rule)
  if rule == CREnum.Tristate.YES then
    entity.grooveChainInflictDamageOnDrop = entity.grooveChainInflictDamageOnDrop or {}
    entity.grooveChainInflictDamageOnDrop.active = true

    entity.grooveChainInflictDamageOnDrop.type = CRSettings.get("characters.missedBeatType")

    local dmg = CRSettings.get("characters.missedBeatDamage")
    if dmg > 0 then
      entity.grooveChainInflictDamageOnDrop.damage = dmg
    end
  elseif rule == CREnum.Tristate.NO then
    entity.grooveChainInflictDamageOnDrop = false
  end

  rule = getTristateSetting("characters.bypassSarcophagus")
  if rule == CREnum.Tristate.YES then
    entity.bypassStairLock = entity.bypassStairLock or { level = 0 }
    entity.bypassStairLock.level = bit.bor(entity.bypassStairLock.level, LevelExit.StairLock.SARCOPHAGUS)
  elseif rule == CREnum.Tristate.NO then
    entity.bypassStairLock = entity.bypassStairLock or { level = 0 }
    entity.bypassStairLock.level = bit.band(entity.bypassStairLock.level, bit.bnot(LevelExit.StairLock.SARCOPHAGUS))
  end
  --#endregion

  --#region Dorian's Rules
  rule = getTristateSetting("characters.cursedBoots")
  if rule == CREnum.Tristate.YES then
    entity.takeDamageOnUntoggledMovement = entity.takeDamageOnUntoggledMovement or {}

    entity.takeDamageOnUntoggledMovement.type = CRSettings.get("characters.cursedBootsType")

    local dmg = CRSettings.get("characters.cursedBootsDamage")
    if dmg > 0 then
      entity.takeDamageOnUntoggledMovement.damage = dmg
    end
  elseif rule == CREnum.Tristate.NO then
    entity.takeDamageOnUntoggledMovement = false
  end
  --#endregion

  --#region Eli's Rules
  rule = getTristateSetting("characters.eliWalls")
  if rule == CREnum.Tristate.YES then
    entity.wallDropSuppressor = entity.wallDropSuppressor or {}
  elseif rule == CREnum.Tristate.NO then
    entity.wallDropSuppressor = false
  end
  --#endregion

  --#region Monk's Rules
  rule = getTristateSetting("characters.poverty")
  if rule == CREnum.Tristate.YES then
    entity.inventoryBannedItems.components.itemCurrency = ItemBan.Flag.PICKUP_DEATH
    entity.inventoryBannedItems.components.itemBanPoverty = ItemBan.Flag.GENERATION
    entity.goldHater = entity.goldHater or {}
  elseif rule == CREnum.Tristate.NO then
    entity.inventoryBannedItems.components.itemCurrency = 0
    entity.inventoryBannedItems.components.itemBanPoverty = 0
    entity.goldHater = false
  end

  rule = getTristateSetting("characters.shoplifter")
  if rule == CREnum.Tristate.YES then
    entity.shoplifter = entity.shoplifter or {}
  elseif rule == CREnum.Tristate.NO then
    entity.shoplifter = false
  end

  rule = getTristateSetting("characters.descentCollect")
  if rule == CREnum.Tristate.YES then
    entity.descentCollectCurrency = entity.descentCollectCurrency or {}
  elseif rule == CREnum.Tristate.NO then
    entity.descentCollectCurrency = false
  end

  rule = getTristateSetting("characters.enemyGold")
  if rule == CREnum.Tristate.YES then
    entity.minimumCurrencyDrop = entity.minimumCurrencyDrop or { minimum = 1 }
  elseif rule == CREnum.Tristate.NO then
    entity.minimumCurrencyDrop = false
  end
  --#endregion

  --#region Dove's rules
  rule = getTristateSetting("characters.teleportingBombs")
  if rule == CREnum.Tristate.YES then
    entity.teleportingBombs = entity.teleportingBombs or {}
  elseif rule == CREnum.Tristate.NO then
    entity.teleportingBombs = false
  end

  rule = getTristateSetting("characters.bypassMiniboss")
  if rule == CREnum.Tristate.YES then
    entity.bypassStairLock = entity.bypassStairLock or { level = 0 }
    entity.bypassStairLock.level = bit.bor(entity.bypassStairLock.level, LevelExit.StairLock.MINIBOSS)
  elseif rule == CREnum.Tristate.NO then
    entity.bypassStairLock = entity.bypassStairLock or { level = 0 }
    entity.bypassStairLock.level = bit.band(entity.bypassStairLock.level, bit.bnot(LevelExit.StairLock.MINIBOSS))
  end
  --#endregion

  --#region Bolt's settings
  rule = CRSettings.get("characters.doubleTime")
  if rule == CREnum.Tristate.YES then
    entity.rhythmSubdivision = entity.rhythmSubdivision or {}
    entity.rhythmSubdivision.factor = 2
  elseif rule == CREnum.Tristate.NO then
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
  rule = CRSettings.get("characters.noBeats")
  if rule == CREnum.Tristate.YES then
    entity.rhythmIgnored = entity.rhythmIgnored or {}
    entity.rhythmIgnoredTemporarily = false
    entity.inventoryBannedItems.components.consumableIgnoreRhythmTemporarily = ItemBan.Type.GENERATION
  elseif rule == CREnum.Tristate.NO then
    entity.rhythmIgnored = false
    entity.rhythmIgnoredTemporarily = entity.rhythmIgnoredTemporarily or {}
    entity.inventoryBannedItems.components.consumableIgnoreRhythmTemporarily = 0
  end
  --#endregion

  --#region Mary's settings
  rule = CRSettings.get("characters.marv")
  if rule == CREnum.Tristate.YES then
    entity.characterWithFollower = { followerType = "Marv" }
  elseif rule == CREnum.Tristate.NO then
    if entity.characterWithFollower and entity.characterWithFollower.followerType == "Marv" then
      entity.characterWithFollower = false
    end
  end
  --#endregion

  --#region Tempo's settings
  rule = CRSettings.get("characters.damageUp")
  if rule == CREnum.Tristate.YES then
    entity.damageIncrease = entity.damageIncrease or { damage = 999 }
    if CRSettings.get("characters.damageUpAmount") > 0 then
      entity.damageIncrease.damage = CRSettings.get("characters.damageUpAmount")
    end
  elseif rule == CREnum.Tristate.NO then
    entity.damageIncrease = {}
  end

  rule = CRSettings.get("characters.killTimer")
  if rule == CREnum.Tristate.YES then
    entity.damageCountdown = entity.damageCountdown or {}
    entity.damageCountdown.countdownReset = entity.damageCountdown.countdownReset or 17
    entity.damageCountdown.damage = entity.damageCountdown.damage or 999
    entity.damageCountdown.killerName = entity.damageCountdown.killerName or "Tempo's Curse"
    entity.soundDamageCountdown = {
      sounds = { "tempoTick4", "tempoTick3", "tempoTick2", "tempoTick1" }
    }
    if CRSettings.get("characters.killTimerDamage") > 0 then
      entity.damageCountdown.damage = CRSettings.get("characters.killTimerDamage")
    end
    entity.damageCountdown.type = CRSettings.get("characters.killTimerType")
    entity.damageCountdownFlyaways = entity.damageCountdownFlyaways or {
      texts = { "0", "1", "2", "3", "4", "5",
        [11] = "10"
      }
    }
  elseif rule == CREnum.Tristate.NO then
    entity.damageCountdown = false
    entity.soundDamageCountdown = false
    entity.damageCountdownFlyaways = false
  end
  --#endregion
  --#endregion

  --#region Inventory rules
  local healthBoost = 0

  --#region Items
  local inv = entity.initialInventory or { items = {} }
  local items = inv.items
  local newItems

  --First, delete the old items if necessary
  local clearInv = CRSettings.get("inventory.items.clear")

  if clearInv then
    newItems = {}
  else
    -- If we're not deleting, we should check for health boosters
    newItems = items
    for i, v in ipairs(items) do
      local boost = CRSchema.healthIncreasingItems[v] or 0
      healthBoost = healthBoost + boost
    end
  end

  --Now pull the new items into the inventory
  local give = CRSettings.get("inventory.items.give")
  for i, v in ipairs(give) do
    local boost = CRSchema.healthIncreasingItems[v] or 0
    healthBoost = healthBoost + boost

    newItems[#newItems + 1] = v
  end

  inv.items = newItems
  entity.initialInventory = inv
  --#endregion
  --#endregion

  --#region Health rules
  if CRSettings.get("advanced") then
    if CRSettings.get("health.use") then
      entity.health = {
        health = CRSettings.get("health.hearts"),
        maxHealth = CRSettings.get("health.containers") - healthBoost
      }
      entity.cursedHealth = {
        health = CRSettings.get("health.cursed")
      }
      entity.healthLimit = {
        limit = CRSettings.get("health.limit")
      }
    end
  end
  --#endregion

  --#region Other
  if CRSettings.get("other.mapGen") ~= 0 then
    entity.playerCharacterLevelGenerationTraits = { mask = CRSettings.get("other.mapGen") }
  end
  --#endregion
end)

--#endregion
