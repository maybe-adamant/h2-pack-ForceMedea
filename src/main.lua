local mods = rom.mods
mods['SGG_Modding-ENVY'].auto()

---@diagnostic disable: lowercase-global
rom = rom
_PLUGIN = _PLUGIN
game = rom.game
modutil = mods['SGG_Modding-ModUtil']
chalk = mods['SGG_Modding-Chalk']
reload = mods['SGG_Modding-ReLoad']
local lib = mods['adamant-ModpackLib']

config = chalk.auto('config.lua')
public.config = config

local backup, revert = lib.createBackupSystem()

-- =============================================================================
-- MODULE DEFINITION
-- =============================================================================

public.definition = {
    id       = "ForceMedea",
    name     = "Force Medea Spawn",
    category = "Run Modifiers",
    group    = "NPCs & Routing",
    tooltip  = "Forces Medea to spawn to reduce death pity reset.",
    default  = false,
    dataMutation = true,
    modpack = "speedrun",
}

-- =============================================================================
-- MODULE LOGIC
-- =============================================================================

local function apply()
    backup(RoomSetData.N.N_Story01, "ForceAtBiomeDepthMin")
    backup(RoomSetData.N.N_Story01, "ForceAtBiomeDepthMax")
    RoomSetData.N.N_Story01.ForceAtBiomeDepthMin = 0
    RoomSetData.N.N_Story01.ForceAtBiomeDepthMax = 1
end

local function registerHooks()
end

-- =============================================================================
-- Wiring
-- =============================================================================

public.definition.apply = apply
public.definition.revert = revert

local loader = reload.auto_single()

modutil.once_loaded.game(function()
    loader.load(function()
        import_as_fallback(rom.game)
        registerHooks()
        if lib.isEnabled(config, public.definition.modpack) then apply() end
        if public.definition.dataMutation and not lib.isCoordinated(public.definition.modpack) then
            SetupRunData()
        end
    end)
end)

local uiCallback = lib.standaloneUI(public.definition, config, apply, revert)
rom.gui.add_to_menu_bar(uiCallback)
