--#region Imports
local Damage          = require "necro.game.system.Damage"
local ItemBan         = require "necro.game.item.ItemBan"
local Settings        = require "necro.config.Settings"
local SettingsStorage = require "necro.config.SettingsStorage"

local PowerSettings = require "PowerSettings.PowerSettings"

local CREnum = require "CharRules.Enum"

local NixLib = require "NixLib.NixLib"

local CSILoaded = pcall(require, "ControlledStartingInventory.CSISettings")
--#endregion Imports

----------------
-- FORMATTERS --
--#region-------

--#endregion

--------------
-- ENABLERS --
--#region-----

--#endregion Enablers

-------------
-- ACTIONS --
--#region----

local function actionReset()
  print(Settings.Visibility)
  local keys = SettingsStorage.listKeys("mod.CharRules", Settings.Layer.REMOTE_OVERRIDE)
  for _, key in ipairs(keys) do
    SettingsStorage.set(key, nil, Settings.Layer.REMOTE_PENDING)
  end
end

--#endregion

--------------
-- SETTINGS --
--#region-----

--#region GENERIC SETTINGS--

Generic = PowerSettings.group {
  id = "generic",
  name = "Generic rules",
  desc = "The basic rules that don't particularly apply to a specific character.",
  order = 0
}

--#region INVENTORY SETTINGS--

GenericInventory = PowerSettings.group {
  id = "generic.inventory",
  name = "Inventory options",
  desc = "Options to manipulate the player inventory",
  order = 0
}

GenericInventoryEnable = PowerSettings.entitySchema.enum {
  id = "generic.inventory.enable",
  name = "Use these options",
  desc = "Whether or not the options on these page should be enabled",
  order = 0,
  enum = CREnum.Inventory
}

GenericInventoryItems = PowerSettings.entitySchema.list.entity {
  id = "generic.inventory.items",
  name = "Items",
  desc = "The items to add or replace",
  order = 1,
  default = {},
  itemDefault = "WeaponDagger",
  filter = "item"
}

--#region ITEM BANS --

GenericInventoryBans = PowerSettings.group {
  id = "generic.inventory.bans",
  name = "Item bans",
  desc = "Enable or disable item bans",
  order = 2
}

GenericInventoryBansEnable = PowerSettings.entitySchema.bool {
  id = "generic.inventory.bans.enable",
  name = "Use these settings?",
  desc = "Should the settings on this page be used?",
  order = 0,
  default = false
}

GenericInventoryBansLabel1 = PowerSettings.entitySchema.label {
  id = "generic.inventory.bans.label1",
  name = "NOTE: Character item bans are under the specific characters.",
  order = 1
}

GenericInventoryBansLabel2 = PowerSettings.entitySchema.label {
  id = "generic.inventory.bans.label2",
  name = "Characters without an item ban option don't have character-specific bans.",
  order = 2
}

GenericInventoryBansItem = PowerSettings.entitySchema.bitflag {
  id = "generic.inventory.bans.item",
  name = "All items",
  desc = "Literally all items including currency",
  order = 3,
  default = 0,
  flags = ItemBan.Flag,
  presets = CREnum.ItemBan
}

GenericInventoryBansConsumableheal = PowerSettings.entitySchema.bitflag {
  id = "generic.inventory.bans.consumableHeal",
  name = "Healing items",
  desc = "Items that restore health",
  order = 4,
  default = 0,
  flags = ItemBan.Flag,
  presets = CREnum.ItemBan
}

GenericInventoryBansItemactivable = PowerSettings.entitySchema.bitflag {
  id = "generic.inventory.bans.itemActivable",
  name = "Familiars",
  desc = "Items that can be activated",
  order = 5,
  default = 0,
  flags = ItemBan.Flag,
  presets = CREnum.ItemBan
}

GenericInventoryBansItemarmor = PowerSettings.entitySchema.bitflag {
  id = "generic.inventory.bans.itemArmor",
  name = "Armor",
  desc = "Armors that reduce incoming damage",
  order = 6,
  default = 0,
  flags = ItemBan.Flag,
  presets = CREnum.ItemBan
}

GenericInventoryBansItembanhealthlocked = PowerSettings.entitySchema.bitflag {
  id = "generic.inventory.bans.itemBanHealthlocked",
  name = "Damage reduction and health-changing items",
  desc = "Items that reduce incoming damage or change the player's heart containers",
  order = 7,
  default = 0,
  flags = ItemBan.Flag,
  presets = CREnum.ItemBan
}

GenericInventoryBansItembannodamage = PowerSettings.entitySchema.bitflag {
  id = "generic.inventory.bans.itemBanNoDamage",
  name = "Damage-increasing items",
  desc = "Items that increase outgoing damge",
  order = 8,
  default = 0,
  flags = ItemBan.Flag,
  presets = CREnum.ItemBan
}

GenericInventoryBansItembanpacifist = PowerSettings.entitySchema.bitflag {
  id = "generic.inventory.bans.itemBanPacifist",
  name = "Damage-dealing or gold-collecting items",
  desc = "Items that cause damge or collect gold",
  order = 9,
  default = 0,
  flags = ItemBan.Flag,
  presets = CREnum.ItemBan
}

GenericInventoryBansItembanpoverty = PowerSettings.entitySchema.bitflag {
  id = "generic.inventory.bans.itemBanPoverty",
  name = "Gold-collecting or spending items",
  desc = "Items that affect the collection or spending of gold",
  order = 10,
  default = 0,
  flags = ItemBan.Flag,
  presets = CREnum.ItemBan
}

GenericInventoryBansItembanweaponlocked = PowerSettings.entitySchema.bitflag {
  id = "generic.inventory.bans.itemBanWeaponlocked",
  name = "Weapons or pain items",
  desc = "Other weapons or pain items",
  order = 11,
  default = 0,
  flags = ItemBan.Flag,
  presets = CREnum.ItemBan
}

GenericInventoryBansItemmoveamplifier = PowerSettings.entitySchema.bitflag {
  id = "generic.inventory.bans.itemMoveAmplifier",
  name = "Move amplifiers",
  desc = "Items that increase move jumps",
  order = 12,
  default = 0,
  flags = ItemBan.Flag,
  presets = CREnum.ItemBan
}

GenericInventoryBansItempurchasepricemultiplier = PowerSettings.entitySchema.bitflag {
  id = "generic.inventory.bans.itemPurchasePriceMultiplier",
  name = "Price-changing items",
  desc = "Items that change the purchase price of other items",
  order = 13,
  default = 0,
  flags = ItemBan.Flag,
  presets = CREnum.ItemBan
}

GenericInventoryBansCustom = PowerSettings.group {
  id = "generic.inventory.bans.custom",
  name = "Custom item bans",
  desc = "Item bans that are defined by the player",
  order = 14,
  visibility = Settings.Visibility.ADVANCED
}

GenericInventoryBansCustomComponents = PowerSettings.entitySchema.list.string {
  id = "generic.inventory.bans.custom.components",
  name = "Ban these components",
  desc = "Select the components to ban",
  order = 0,
  visibility = Settings.Visibility.ADVANCED,
  itemDefault = ""
}

GenericInventoryBansCustomItems = PowerSettings.entitySchema.list.entity {
  id = "generic.inventory.bans.custom.items",
  name = "Ban these items",
  desc = "Select the items to ban",
  order = 1,
  visibility = Settings.Visibility.ADVANCED,
  filter = "item",
  itemDefault = "Food1"
}

GenericInventoryBansCustomFlags = PowerSettings.entitySchema.bitflag {
  id = "generic.inventory.bans.custom.flags",
  name = "Flags for these bans",
  desc = "Select the flags for these bans",
  order = 2,
  visibility = Settings.Visibility.ADVANCED,
  default = 0,
  flags = ItemBan.Flag,
  presets = CREnum.ItemBan
}

--#endregion
--#endregion
--#region HEALTH SETTINGS--

GenericHealth = PowerSettings.group {
  id = "generic.health",
  name = "Health settings",
  desc = "Settings affecting the player's health",
  order = 1
}

GenericHealthEnable = PowerSettings.entitySchema.bool {
  id = "generic.health.enable",
  name = "Use these settings",
  desc = "Enables the settings on this screen",
  order = 0,
  default = false
}

GenericHealthAmount = PowerSettings.entitySchema.number {
  id = "generic.health.amount",
  name = "Starting health",
  desc = "The health with which the player starts",
  order = 1,
  default = 6,
  minimum = 1,
  upperBound = function()
    if SettingsStorage.get("config.showAdvanced") then
      return SettingsStorage.get("mod.CharRules.generic.health.max", Settings.Layer.REMOTE_PENDING) or
          SettingsStorage.getDefaultValue("mod.CharRules.generic.health.max")
    else
      return 20
    end
  end
}

GenericHealthMax = PowerSettings.entitySchema.number {
  id = "generic.health.max",
  name = "Starting health containers",
  desc = "The heart containers with which the player starts",
  order = 2,
  default = 6,
  lowerBound = "generic.health.amount",
  upperBound = function()
    local limit = SettingsStorage.get("mod.CharRules.generic.health.limit", Settings.Layer.REMOTE_PENDING) or
        SettingsStorage.getDefaultValue("mod.CharRules.generic.health.limit")
    local cursed = SettingsStorage.get("mod.CharRules.generic.health.cursed", Settings.Layer.REMOTE_PENDING) or
        SettingsStorage.getDefaultValue("mod.CharRules.generic.health.cursed")

    return limit - cursed
  end,
  visibility = Settings.Visibility.ADVANCED
}

GenericHealthCursed = PowerSettings.entitySchema.number {
  id = "generic.health.cursed",
  name = "Starting cursed health",
  desc = "The cursed health with which the player starts",
  order = 3,
  default = 0,
  minimum = 0,
  upperBound = function()
    local limit = SettingsStorage.get("mod.CharRules.generic.health.limit", Settings.Layer.REMOTE_PENDING) or
        SettingsStorage.getDefaultValue("mod.CharRules.generic.health.limit")
    local max = SettingsStorage.get("mod.CharRules.generic.health.max", Settings.Layer.REMOTE_PENDING) or
        SettingsStorage.getDefaultValue("mod.CharRules.generic.health.max")

    return limit - max
  end,
  visibility = Settings.Visibility.ADVANCED
}

GenericHealthLimit = PowerSettings.entitySchema.number {
  id = "generic.health.limit",
  name = "Maximum health containers",
  desc = "The number of heart containers above which the player can have no more",
  default = 20,
  order = 4,
  lowerBound = function()
    local cursed = SettingsStorage.get("mod.CharRules.generic.health.cursed", Settings.Layer.REMOTE_PENDING) or
        SettingsStorage.getDefaultValue("mod.CharRules.generic.health.cursed")
    local max = SettingsStorage.get("mod.CharRules.generic.health.max", Settings.Layer.REMOTE_PENDING) or
        SettingsStorage.getDefaultValue("mod.CharRules.generic.health.max")

    return cursed + max
  end,
  maximum = 20,
  visibility = Settings.Visibility.ADVANCED
}

--#endregion
--#endregion
--#region CHARACTER SETTINGS--

Character = PowerSettings.group {
  id = "character",
  name = "Character rules",
  desc = "The rules that do apply to specific characters",
  order = 1
}

--#region ARIA SETTINGS--

CharacterAria = PowerSettings.group {
  id = "character.aria",
  name = "Aria",
  desc = "Aria's rules",
  order = 0
}

CharacterAriaMissedbeat = PowerSettings.entitySchema.enum {
  id = "character.aria.missedBeat",
  name = "Missed beat",
  desc = "Whether or not a missed beat causes damage",
  order = 0,
  enum = CREnum.Tristate,
  default = CREnum.Tristate.DEFAULT
}

CharacterAriaDamage = PowerSettings.entitySchema.number {
  id = "character.aria.damage",
  name = "Damage from missed beat",
  desc = "Damage taken from a missed beat",
  order = 1,
  default = 1,
  minimum = 1,
  maximum = 20,
  visibility = Settings.Visibility.ADVANCED
}

CharacterAriaDamagetype = PowerSettings.entitySchema.bitflag {
  id = "character.aria.damageType",
  name = "Damage type from missed beat",
  desc = "The type of damage taken by mixed beat",
  order = 2,
  default = Damage.Type.SELF_DAMAGE,
  flags = Damage.Flag,
  presets = Damage.Type,
  visibility = Settings.Visibility.ADVANCED
}

CharacterAriaBypassstairlock = PowerSettings.entitySchema.enum {
  id = "character.aria.bypassStairlock",
  name = "Bypass sarcophagus stair lock",
  desc = "Whether or not stairs should be locked until a sarcophagus is destroyed",
  order = 3,
  enum = CREnum.Tristate,
  default = CREnum.Tristate.DEFAULT
}

CharacterAriaItembans = PowerSettings.entitySchema.enum {
  id = "character.aria.itemBans",
  name = "Use Aria's item bans",
  desc = "Whether or not Aria's item bans should be applied",
  order = 4,
  enum = CREnum.Tristate,
  default = CREnum.Tristate.DEFAULT
}

--#endregion

--#region DORIAN SETTINGS--

CharacterDorian = PowerSettings.group {
  id = "character.dorian",
  name = "Dorian",
  desc = "Settings related to Dorian",
  order = 1
}

CharacterDorianCursed = PowerSettings.entitySchema.enum {
  id = "character.dorian.cursed",
  name = "Cursed boots",
  desc = "Take damage while wearing disabled boots of leaping or lunging",
  order = 0,
  enum = CREnum.Tristate,
  default = CREnum.Tristate.DEFAULT
}

CharacterDorianCustomize = PowerSettings.group {
  id = "character.dorian.customize",
  name = "Customize",
  desc = "Customize the untoggled movement damage settings",
  order = 1,
  visibility = Settings.Visibility.ADVANCED
}

CharacterDorianCustomizeDamage = PowerSettings.entitySchema.number {
  id = "character.dorian.customize.damage",
  name = "Damage taken from cursed boots",
  desc = "Damage taken from disabled boots of leaping or lunging",
  order = 0,
  default = 1,
  minimum = 0,
  maximum = 999,
  editAsString = true,
  visibility = Settings.Visibility.ADVANCED
}

CharacterDorianCustomizeType = PowerSettings.entitySchema.bitflag {
  id = "character.dorian.customize.type",
  name = "Damage type from cursed boots",
  desc = "The type of damage taken from disabled boots of leaping or lunging",
  order = 2,
  default = Damage.Type.BLOOD,
  flags = Damage.Flag,
  presets = Damage.Type,
  visibility = Settings.Visibility.ADVANCED
}

--#endregion

--#region ELI SETTINGS--

CharacterEli = PowerSettings.group {
  id = "character.eli",
  name = "Eli",
  desc = "Settings for Eli",
  order = 2
}

CharacterEliWallgold = PowerSettings.entitySchema.enum {
  id = "character.eli.wallGold",
  name = "Receive gold from shop walls",
  desc = "Whether or not the character should receive gold from destroyed shop walls",
  order = 0,
  enum = CREnum.Tristate,
  default = CREnum.Tristate.DEFAULT
}

--#endregion

--#region MONK SETTINGS--

CharacterMonk = PowerSettings.group {
  id = "character.monk",
  name = "Monk",
  desc = "Monk's settings",
  order = 3
}

CharacterMonkShoplifter = PowerSettings.entitySchema.enum {
  id = "character.monk.shoplifter",
  name = "Free items from shops",
  desc = "Character receives one free item per shop",
  order = 0,
  enum = CREnum.Tristate,
  default = CREnum.Tristate.DEFAULT
}

CharacterMonkGoldkills = PowerSettings.entitySchema.enum {
  id = "character.monk.goldKills",
  name = "Gold kills on pickup",
  desc = "Character dies when picking up gold",
  order = 1,
  enum = CREnum.Tristate,
  default = CREnum.Tristate.DEFAULT
}

CharacterMonkGoldhater = PowerSettings.entitySchema.enum {
  id = "character.monk.goldHater",
  name = "Poverty gameplay adjustments",
  desc = "Leprechauns don't drop gold on death, Earth spell removes gold",
  order = 2,
  enum = CREnum.Tristate,
  default = CREnum.Tristate.DEFAULT
}

CharacterMonkDescentcollect = PowerSettings.entitySchema.enum {
  id = "character.monk.descentCollect",
  name = "Collect gold on stairs",
  desc = "When descending the stairs, pickup all dropped gold",
  order = 3,
  enum = CREnum.Tristate,
  default = CREnum.Tristate.DEFAULT
}

CharacterMonkEnemydrops = PowerSettings.entitySchema.enum {
  id = "character.monk.enemyDrops",
  name = "All enemies drop gold",
  desc = "All enemies drop at least one gold when killed",
  order = 4,
  enum = CREnum.Tristate,
  default = CREnum.Tristate.DEFAULT
}

CharacterMonkMinimumgold = PowerSettings.entitySchema.number {
  id = "character.monk.minimumGold",
  name = "Minimum gold from enemies",
  desc = "Minimum gold dropped by enemies if above option is on",
  order = 5,
  minimum = 0,
  default = 1,
  visibility = Settings.Visibility.ADVANCED
}

--#endregion

--#region DOVE SETTINGS--

CharacterDove = PowerSettings.group {
  id = "character.dove",
  name = "Dove",
  desc = "Dove's settings",
  order = 4
}

CharacterDoveSongendcast = PowerSettings.entitySchema.enum {
  id = "character.dove.songEndCast",
  name = "Die on end of song",
  desc = "When the song ends, players die instead of descending.",
  order = 0,
  enum = CREnum.Tristate,
  default = CREnum.Tristate.DEFAULT
}

CharacterDoveTeleportingbombs = PowerSettings.entitySchema.enum {
  id = "character.dove.teleportingBombs",
  name = "Bombs teleport enemies",
  desc = "When enemies are hit by bombs, they're teleported instead of damaged.",
  order = 1,
  enum = CREnum.Tristate,
  default = CREnum.Tristate.DEFAULT
}

CharacterDoveMiniboss = PowerSettings.entitySchema.enum {
  id = "character.dove.miniboss",
  name = "Bypass minibosses",
  desc = "Should minibosses be bypassed for the stairs lock?",
  order = 2,
  enum = CREnum.Tristate,
  default = CREnum.Tristate.DEFAULT
}

--#endregion
--#endregion

return {
  get = function(entry)
    return SettingsStorage.get("mod.CharRules." .. entry)
  end
}
