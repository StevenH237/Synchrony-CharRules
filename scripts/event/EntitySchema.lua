local Event     = require "necro.event.Event"
local ItemBan   = require "necro.game.item.ItemBan"
local LevelExit = require "necro.game.tile.LevelExit"
local RNG       = require "necro.game.system.RNG"
local Utilities = require "system.utils.Utilities"

local CRSettings = require "CharRules.Settings"
local CREnum     = require "CharRules.Enum"
local CRSchema   = require "CharRules.Schema"

local Tristate = CREnum.Tristate

------------------
-- RNG CHANNELS --
--#region---------

local RNGChannel = {}

--#endregion

---------------
-- CONSTANTS --
--#region------

local ItemBanFlags = ItemBan.Flag.PICKUP
    + ItemBan.Flag.GENERATE_ITEM_POOL
    + ItemBan.Flag.GENERATE_CRATE
    + ItemBan.Flag.GENERATE_SHRINE_FIXED
    + ItemBan.Flag.GENERATE_SHRINE_POOL
    + ItemBan.Flag.GENERATE_SHRINE_DROP
    + ItemBan.Flag.GENERATE_LEVEL
    + ItemBan.Flag.GENERATE_TRANSACTION

--#endregion Constants

---------------
-- VARIABLES --
--#region------

local MapGenRules = {
  bossSarcophagus  = nil,
  innatePeace      = nil,
  noGoldInVaults   = nil,
  reverseZoneOrder = nil,
  skipBosses       = nil,
  smallerShops     = nil,
  storyBosses      = nil
}

---------------
-- FUNCTIONS --
--#region------

local function getTristate(setting)
  local quat = CRSettings.get(setting)

  -- We're gonna use an rng call no matter what, so that the randomization isn't determined by which settings are set to random.
  local randomTristate = RNG.choice({ Tristate.NO, Tristate.DEFAULT, Tristate.YES }, RNGChannel)

  if quat == CREnum.Quatristate.NO then
    return Tristate.NO
  elseif quat == CREnum.Quatristate.DEFAULT then
    return Tristate.DEFAULT
  elseif quat == CREnum.Quatristate.YES then
    return Tristate.YES
  else
    return randomTristate
  end
end

--#endregion

------------
-- EVENTS --
--#region---

Event.entitySchemaGenerate.add("checks", { order = "components", sequence = -1 }, function()
  RNGChannel = {
    state1 = 237,
    state2 = 242778437, -- "CHARRULES" on a keypad
    state3 = CRSettings.get("random")
  }

  -- We'll do map gen rule calls *here* so that all characters are consistent
  MapGenRules = {
    bossSarcophagus  = getTristate("mapGen.bossSarcophagus"),
    innatePeace      = getTristate("mapGen.innatePeace"),
    noGoldInVaults   = getTristate("mapGen.noGoldInVaults"),
    reverseZoneOrder = getTristate("mapGen.reverseZoneOrder"),
    skipBosses       = getTristate("mapGen.skipBosses"),
    smallerShops     = getTristate("mapGen.smallerShops"),
    storyBosses      = getTristate("mapGen.storyBosses"),
  }
end)

Event.entitySchemaLoadPlayer.add("charRulesComponents", { order = "overrides", sequence = 2 }, function(ev)
  local entity = ev.entity

  if entity.name == nil then return end -- gdi reaper

  entity.inventoryBannedItems = entity.inventoryBannedItems or { components = {} }
  entity.inventoryBannedItems.components = entity.inventoryBannedItems.components or {}

  entity.itemCollectorBannedPickupDamage = {}

  entity.bypassStairLock = entity.bypassStairLock or { level = 0 }
  entity.bypassStairLock.level = entity.bypassStairLock.level or LevelExit.StairLock.MINIBOSS

  --#region Character-specific rules
  --#region Aria's rules
  local rule = getTristate("characters.missedBeat")
  if rule == Tristate.YES then
    entity.grooveChainInflictDamageOnDrop = entity.grooveChainInflictDamageOnDrop or {}
    entity.grooveChainInflictDamageOnDrop.active = true

    entity.grooveChainInflictDamageOnDrop.type = CRSettings.get("characters.missedBeatType")

    local dmg = CRSettings.get("characters.missedBeatDamage")
    if dmg > 0 then
      entity.grooveChainInflictDamageOnDrop.damage = dmg
    end
  elseif rule == Tristate.NO then
    entity.grooveChainInflictDamageOnDrop = entity.grooveChainInflictDamageOnDrop or {}
    entity.grooveChainInflictDamageOnDrop.active = false
  end

  rule = getTristate("characters.bypassSarcophagus")
  if rule == Tristate.YES then
    entity.bypassStairLock = entity.bypassStairLock or { level = 0 }
    entity.bypassStairLock.level = bit.bor(entity.bypassStairLock.level, LevelExit.StairLock.SARCOPHAGUS)
  elseif rule == Tristate.NO then
    entity.bypassStairLock = entity.bypassStairLock or { level = 0 }
    entity.bypassStairLock.level = bit.band(entity.bypassStairLock.level, bit.bnot(LevelExit.StairLock.SARCOPHAGUS))
  end
  --#endregion

  --#region Dorian's Rules
  rule = getTristate("characters.cursedBoots")
  if rule == Tristate.YES then
    entity.takeDamageOnUntoggledMovement = entity.takeDamageOnUntoggledMovement or {}

    entity.takeDamageOnUntoggledMovement.type = CRSettings.get("characters.cursedBootsType")

    local dmg = CRSettings.get("characters.cursedBootsDamage")
    if dmg > 0 then
      entity.takeDamageOnUntoggledMovement.damage = dmg
    end
  elseif rule == Tristate.NO then
    entity.takeDamageOnUntoggledMovement = false
  end
  --#endregion

  --#region Eli's Rules
  rule = getTristate("characters.eliWalls")
  if rule == Tristate.YES then
    entity.wallDropSuppressor = entity.wallDropSuppressor or {}
  elseif rule == Tristate.NO then
    entity.wallDropSuppressor = false
  end
  --#endregion

  --#region Monk's Rules
  rule = getTristate("characters.poverty")
  if rule == Tristate.YES then
    entity.inventoryBannedItems.components.itemBanKillPoverty = ItemBan.Flag.PICKUP_DEATH
    entity.inventoryBannedItems.components.itemBanPoverty = ItemBan.Flag.GENERATION
    entity.goldHater = entity.goldHater or {}
  elseif rule == Tristate.NO then
    entity.inventoryBannedItems.components.itemBanKillPoverty = 0
    entity.inventoryBannedItems.components.itemBanPoverty = 0
    entity.goldHater = false
  end

  rule = getTristate("characters.shoplifter")
  if rule == Tristate.YES then
    entity.shoplifter = entity.shoplifter or {}
  elseif rule == Tristate.NO then
    entity.shoplifter = false
  end

  rule = getTristate("characters.descentCollect")
  if rule == Tristate.YES then
    entity.descentCollectCurrency = entity.descentCollectCurrency or {}
  elseif rule == Tristate.NO then
    entity.descentCollectCurrency = false
  end

  rule = getTristate("characters.enemyGold")
  if rule == Tristate.YES then
    entity.minimumCurrencyDrop = entity.minimumCurrencyDrop or { minimum = 1 }
  elseif rule == Tristate.NO then
    entity.minimumCurrencyDrop = false
  end
  --#endregion

  --#region Dove's rules
  rule = getTristate("characters.teleportingBombs")
  if rule == Tristate.YES then
    entity.teleportingBombs = entity.teleportingBombs or {}
  elseif rule == Tristate.NO then
    entity.teleportingBombs = false
  end

  rule = getTristate("characters.bypassMiniboss")
  if rule == Tristate.YES then
    entity.bypassStairLock = entity.bypassStairLock or { level = 0 }
    entity.bypassStairLock.level = bit.bor(entity.bypassStairLock.level, LevelExit.StairLock.MINIBOSS)
  elseif rule == Tristate.NO then
    entity.bypassStairLock = entity.bypassStairLock or { level = 0 }
    entity.bypassStairLock.level = bit.band(entity.bypassStairLock.level, bit.bnot(LevelExit.StairLock.MINIBOSS))
  end
  --#endregion

  --#region Bolt's settings
  if CRSettings.get("characters.customTempo") > 1 then
    entity.rhythmSubdivision = entity.rhythmSubdivision or {}
    entity.rhythmSubdivision.factor = CRSettings.get("characters.customTempo")
  elseif CRSettings.get("characters.customTempo") == 1 then
    entity.rhythmSubdivision = false
  end
  --#endregion

  --#region Bard's settings
  rule = CRSettings.get("characters.noBeats")
  if rule == Tristate.YES then
    entity.rhythmIgnored = entity.rhythmIgnored or {}
    entity.rhythmIgnoredTemporarily = false
    entity.inventoryBannedItems.components.consumableIgnoreRhythmTemporarily = ItemBan.Type.GENERATION
  elseif rule == Tristate.NO then
    entity.rhythmIgnored = false
    entity.rhythmIgnoredTemporarily = entity.rhythmIgnoredTemporarily or {}
    entity.inventoryBannedItems.components.consumableIgnoreRhythmTemporarily = 0
  end
  --#endregion

  --#region Mary's settings
  rule = CRSettings.get("characters.marv")
  if rule == Tristate.YES then
    entity.characterWithFollower = { followerType = "Marv" }
  elseif rule == Tristate.NO then
    if entity.characterWithFollower and entity.characterWithFollower.followerType == "Marv" then
      entity.characterWithFollower = false
    end
  end
  --#endregion

  --#region Tempo's settings
  rule = CRSettings.get("characters.damageUp")
  if rule == Tristate.YES then
    entity.damageIncrease = entity.damageIncrease or { damage = 999 }
    if CRSettings.get("characters.damageUpAmount") > 0 then
      entity.damageIncrease.damage = CRSettings.get("characters.damageUpAmount")
    end
  elseif rule == Tristate.NO then
    entity.damageIncrease = {}
  end

  rule = CRSettings.get("characters.killTimer")
  if rule == Tristate.YES then
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
  elseif rule == Tristate.NO then
    entity.damageCountdown = false
    entity.soundDamageCountdown = false
    entity.damageCountdownFlyaways = false
  end
  --#endregion
  --#endregion

  --#region Unspecific rules
  local act = CRSettings.get("unspecific.actions")
  print("Action set: " .. CREnum.ActionSets.data[act].name)
  if act ~= CREnum.ActionSets.DEFAULT then
    entity.actionFilter = Utilities.fastCopy(CREnum.ActionSets.data[act].actionFilter)
    entity.actionRemap = Utilities.fastCopy(CREnum.ActionSets.data[act].actionRemap)
    print(entity.actionFilter)
    print(entity.actionRemap)
  end
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

  --#region Item bans
  local banFlags = entity.inventoryBannedItems or { components = {} }
  local comps = banFlags.components

  rule = getTristate("inventory.bans.cirt")
  if rule == Tristate.YES then
    comps.consumableIgnoreRhythmTemporarily = ItemBanFlags
  elseif rule == Tristate.NO then
    comps.consumableIgnoreRhythmTemporarily = nil
  end

  rule = getTristate("inventory.bans.healthlocked")
  if rule == Tristate.YES then
    comps.itemBanHealthlocked = ItemBanFlags
  elseif rule == Tristate.NO then
    comps.itemBanHealthlocked = nil
  end

  rule = getTristate("inventory.bans.noDamage")
  if rule == Tristate.YES then
    comps.itemBanNoDamage = ItemBanFlags
  elseif rule == Tristate.NO then
    comps.itemBanNoDamage = nil
  end

  rule = getTristate("inventory.bans.pacifist")
  if rule == Tristate.YES then
    comps.itemBanPacifist = ItemBanFlags
  elseif rule == Tristate.NO then
    comps.itemBanPacifist = nil
  end

  rule = getTristate("inventory.bans.poverty")
  if rule == Tristate.YES then
    comps.itemBanPoverty = ItemBanFlags
    comps.itemBanKillPoverty = ItemBanFlags
  elseif rule == Tristate.NO then
    comps.itemBanPoverty = nil
    comps.itemBanKillPoverty = nil
  end

  rule = getTristate("inventory.bans.weaponlocked")
  if rule == Tristate.YES then
    comps.itemBanWeaponlocked = ItemBanFlags
  elseif rule == Tristate.NO then
    comps.itemBanWeaponlocked = nil
  end

  rule = getTristate("inventory.bans.grooveChainImmunity")
  if rule == Tristate.YES then
    comps.itemGrooveChainImmunity = ItemBanFlags
  elseif rule == Tristate.NO then
    comps.itemGrooveChainImmunity = nil
  end

  entity.inventoryBannedItems = banFlags
  --#endregion

  --#region Slot curses
  local cursedSlots = entity.inventoryCursedSlots or { slots = {} }
  local slots = cursedSlots.slots

  rule = getTristate("inventory.curses.action")
  if rule == Tristate.YES then
    slots.action = true
  elseif rule == Tristate.NO then
    slots.action = nil
  end

  rule = getTristate("inventory.curses.shovel")
  if rule == Tristate.YES then
    slots.shovel = true
  elseif rule == Tristate.NO then
    slots.shovel = nil
  end

  rule = getTristate("inventory.curses.weapon")
  if rule == Tristate.YES then
    slots.weapon = true
  elseif rule == Tristate.NO then
    slots.weapon = nil
  end

  rule = getTristate("inventory.curses.body")
  if rule == Tristate.YES then
    slots.body = true
  elseif rule == Tristate.NO then
    slots.body = nil
  end

  rule = getTristate("inventory.curses.head")
  if rule == Tristate.YES then
    slots.head = true
  elseif rule == Tristate.NO then
    slots.head = nil
  end

  rule = getTristate("inventory.curses.feet")
  if rule == Tristate.YES then
    slots.feet = true
  elseif rule == Tristate.NO then
    slots.feet = nil
  end

  rule = getTristate("inventory.curses.torch")
  if rule == Tristate.YES then
    slots.torch = true
  elseif rule == Tristate.NO then
    slots.torch = nil
  end

  rule = getTristate("inventory.curses.ring")
  if rule == Tristate.YES then
    slots.ring = true
  elseif rule == Tristate.NO then
    slots.ring = nil
  end

  rule = getTristate("inventory.curses.misc")
  if rule == Tristate.YES then
    slots.misc = true
  elseif rule == Tristate.NO then
    slots.misc = nil
  end

  rule = getTristate("inventory.curses.spell")
  if rule == Tristate.YES then
    slots.spell = true
  elseif rule == Tristate.NO then
    slots.spell = nil
  end

  entity.inventoryCursedSlots = cursedSlots
  --#endregion
  --#endregion

  --#region Health rules
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
  --#endregion

  --#region Map gen
  if MapGenRules.bossSarcophagus == Tristate.YES then
    entity.traitBossSarcophagus = entity.traitBossSarcophagus or {}
  elseif MapGenRules.bossSarcophagus == Tristate.NO then
    entity.traitBossSarcophagus = false
  end

  if MapGenRules.innatePeace == Tristate.YES then
    entity.traitInnatePeace = entity.traitInnatePeace or {}
  elseif MapGenRules.innatePeace == Tristate.NO then
    entity.traitInnatePeace = false
  end

  if MapGenRules.noGoldInVaults == Tristate.YES then
    entity.traitNoGoldInVaults = entity.traitNoGoldInVaults or {}
  elseif MapGenRules.noGoldInVaults == Tristate.NO then
    entity.traitNoGoldInVaults = false
  end

  if MapGenRules.reverseZoneOrder == Tristate.YES then
    entity.traitReverseZoneOrder = entity.traitReverseZoneOrder or {}
  elseif MapGenRules.reverseZoneOrder == Tristate.NO then
    entity.traitReverseZoneOrder = false
  end

  if MapGenRules.skipBosses == Tristate.YES then
    entity.traitSkipBosses = entity.traitSkipBosses or {}
  elseif MapGenRules.skipBosses == Tristate.NO then
    entity.traitSkipBosses = false
  end

  if MapGenRules.smallerShops == Tristate.YES then
    entity.traitSmallerShops = entity.traitSmallerShops or {}
  elseif MapGenRules.smallerShops == Tristate.NO then
    entity.traitSmallerShops = false
  end

  if MapGenRules.storyBosses == Tristate.YES then
    entity.traitStoryBosses = { bosses = CRSettings.get("mapGen.storyBossList") }
  elseif MapGenRules.storyBosses == Tristate.NO then
    entity.traitStoryBosses = false
  end
  --#endregion
end)

--#endregion
