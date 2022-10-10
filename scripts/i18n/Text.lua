return {
  ActionSets = {
    CharDefault = L("Character default", "actionSets.charDefault"),
    Diamond = L("Diamond movement (8-way + Item/bomb)", "actionSets.diamond"),
    Diamond2 = L("8-way + Spells", "actionSets.diamond2"),
    Skew = L("Skew (U-UR-D-DL)", "actionSets.skew"),
    Standard = L("Standard", "actionSets.standard")
  },
  Formats = {
    Default = L("(Default)", "formats.default"),
    Disabled = L("(Disabled)", "formats.disabled"),
    None = L("(None)", "formats.none"),
    Hearts05 = L("1 (0.5 heart)", "formats.hearts05"),
    Hearts1 = L("2 (1 heart)", "formats.hearts1"),
    Hearts15 = L("3 (1.5 hearts)", "formats.hearts15"),
    Hearts2 = L("4 (2 hearts)", "formats.hearts2"),
    Hearts25 = L("5 (2.5 hearts)", "formats.hearts25"),
    HeartsPlus = function(...) return L.formatKey("%d (%d hearts)", "formats.heartsPlus", ...) end
  },
  ItemBans = {
    Full = L("Don't pick up, drop, or generate", "itemBans.full"),
    FullDeadly = L("Don't drop or generate, kill on pickup", "itemBans.fullDeadly"),
    Generation = L("Don't generate except shrines", "itemBans.generation"),
    GenerationAll = L("Don't generate at all", "itemBans.generationAll"),
    Lock = L("Don't pick up or drop", "itemBans.lock"),
    None = L("No bans", "itemBans.none"),
    PickupDeath = L("Kill player on pickup", "itemBans.pickupDeath")
  }
}
