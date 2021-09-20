local CRSettings = require "CharRules.CRSettings"
local Event      = require "necro.event.Event"

------------
-- TABLES --
--#region---

local invStartTable, invBansTable, invCursedTable

--#endregion

------------
-- EVENTS --
--#region---

Event.entitySchemaGenerate.add("charRulesFunctions", {order="components", sequence=-1}, function ()
  invStartTable = CRSettings.getList("inv.start")
  invBansTable = CRSettings.getSet("inv.bans")
  invCursedTable = CRSettings.getSet("inv.cursed")

  if invBansTable then for k, v in pairs(invBansTable) do
    if v == true then invBansTable[k] = 4161537 end
  end end
end)

Event.entitySchemaLoadEntity.add("charRulesComponents", {order="overrides"}, function(ev)
  local entity = ev.entity

  if not entity.playableCharacter then return end

  --#region HEALTH SETTINGS --

  local startHealth = CRSettings.get("health.start")
  local startMax = CRSettings.get("health.startMax")
  local startCursed = CRSettings.get("health.startCursed")
  local healthLimit = CRSettings.get("health.limit")

  if startHealth > 0 or startMax > 0 then
    local cmpHealth = entity.health or {}

    if startHealth > 0 then cmpHealth.health = startHealth end
    if startMax > 0 then cmpHealth.maxHealth = startMax end

    entity.health = cmpHealth
  end

  if startCursed > 0 then
    local cmpCursed = entity.cursedHealth or {}
    cmpCursed.health = startCursed
    entity.cursedHealth = cmpCursed
  end

  if healthLimit > 0 then
    local cmpLimit = entity.healthLimit or {}
    cmpLimit.limit = healthLimit
    entity.healthLimit = cmpLimit
  end

  --#endregion
  --#region INVENTORY SETTINGS --

  if invStartTable then
    local initInv = entity.initialInventory or {}
    initInv.items = invStartTable
    entity.initialInventory = initInv
  end

  if invBansTable then
    local bans = entity.inventoryBannedItems or {}
    bans.components = invBansTable
    entity.inventoryBannedItems = bans
  end

  if invCursedTable then
    local curses = entity.inventoryCursedSlots or {}
    curses.slots = invCursedTable
    entity.inventoryCursedSlots = curses
  end

  --#endregion
  --#region RHYTHM SETTINGS --

  local fixedBeat = CRSettings.get("rhythm.fixed")
  local multiplier = CRSettings.get("rhythm.multiplier")
  local songEnd = CRSettings.get("rhythm.songEnd")

  if fixedBeat == -1 then
    entity.rhythmIgnoredTemporarily = entity.rhythmIgnoredTemporarily or {}
    entity.rhythmIgnored = false
  elseif fixedBeat == 1 then
    entity.rhythmIgnored = entity.rhythmIgnored or {}
    entity.rhythmIgnoredTemporarily = false
  end

  if multiplier > 0 then
    local subdiv = entity.rhythmSubdivision or {}
    subdiv.factor = multiplier
    entity.rhythmSubdivision = subdiv
  end

  if songEnd == 2 then
    local cast = entity.songEndCast or {}
    cast.spell = "SpellcastSongEnd"
    entity.songEndCast = cast
  elseif songEnd == 1 then
    local cast = entity.songEndCast or {}
    cast.spell = "SpellcastSuicide"
    entity.songEndCast = cast
  end

  --#endregion
  --#region GROOVE SETTINGS --
  --#region ├─ GROOVE LEVELS --

  local grooveLevelFirst = CRSettings.get("groove.level.first")
  local grooveLevelEach = CRSettings.get("groove.level.each")
  local grooveLevelTotal = CRSettings.get("groove.level.total")

  if grooveLevelFirst > 0 or grooveLevelEach > 0 or grooveLevelTotal > 0 then
    local groove = entity.grooveChain or {}

    if grooveLevelFirst > 0 then groove.killsForInitMultiplier = grooveLevelFirst end
    if grooveLevelEach > 0 then groove.killsPerMultiplier = grooveLevelEach end
    if grooveLevelTotal > 0 then groove.maximumMultiplier = grooveLevelTotal end

    entity.grooveChain = groove
  end

  --#endregion
  --#region └─ GROOVE DROP --
  
  --#endregion
  --#endregion
end)

--#endregion