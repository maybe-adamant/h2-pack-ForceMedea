local mods = rom.mods
mods['SGG_Modding-ENVY'].auto()

---@diagnostic disable: lowercase-global
rom = rom
_PLUGIN = _PLUGIN
game = rom.game
modutil = mods['SGG_Modding-ModUtil']
chalk = mods['SGG_Modding-Chalk']
reload = mods['SGG_Modding-ReLoad']
local lib = mods['adamant-Modpack_Lib']

config = chalk.auto('config.lua')
public.config = config

local backup, restore = lib.createBackupSystem()

-- =============================================================================
-- MODULE DEFINITION
-- =============================================================================

public.definition = {
    id       = "ForceMedea",
    name     = "Force Medea Spawn",
    category = "RunModifiers",
    group    = "NPCs & Routing",
    tooltip  = "Forces Medea to spawn to reduce death pity reset.",
    default  = false,
    dataMutation = true,
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

public.definition.enable = apply
public.definition.disable = restore

local loader = reload.auto_single()

modutil.once_loaded.game(function()
    loader.load(function()
        import_as_fallback(rom.game)
        registerHooks()
        if lib.isEnabled(config) then apply() end
        if public.definition.dataMutation and not mods['adamant-Modpack_Core'] then
            SetupRunData()
        end
    end)
end)

local uiCallback = lib.standaloneUI(public.definition, config, apply, restore)
rom.gui.add_to_menu_bar(uiCallback)
