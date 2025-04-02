-- Toml-helper v1.1.0
-- SmoothSpatula

-- == Setup == --

envy = mods["MGReturns-ENVY"]
envy.auto()

-- == Data == --

Toml = {}
local cfg_path = path.get_parent(_ENV["!config_mod_folder_path"])
local cfg_name = "cfg.toml"

local cfg_defaults = {} -- stores the default cfgs
local cfg_flags = {} -- stores the flags
local save_buffer = {} -- stores the tables to be saved

-- == Helper Functions == --

-- Recursively removes all empty tables 
local remove_empty_tables_rec
remove_empty_tables_rec = function(tab)
    for k, v in pairs(tab) do
        if type(v) == "table" then
            if next(v) == nil then
                tab[k] = nil
            else 
                remove_empty_tables_rec(v)
                if next(v) == nil then -- check again in case it only contained empty tables which got deleted
                    tab[k] = nil
                end
            end
        end
    end
end

-- for testing purposes
-- function print_table(tab)
--     for k, v in pairs(tab) do
--         print(k, v)
--         if type(v) == "table" then
--             print_table(v)
--         end
--     end
-- end

-- from islet8 on StackOverflow https://stackoverflow.com/a/16077650
local function deepcopy(o, seen)
    seen = seen or {}
    if o == nil then return nil end
    if seen[o] then return seen[o] end
    local no
    if type(o) == 'table' then
        no = {}
        seen[o] = no
    
        for k, v in next, o, nil do
            no[deepcopy(k, seen)] = deepcopy(v, seen)
        end
    else -- number, string, boolean, etc
        no = o
    end
    return no
end

-- == Private Functions == --

local save_cfg_internal = function(plugin_name, tab)
    local full_path = path.combine(cfg_path, plugin_name, cfg_name)

    -- remove empty tables from the cfg
    local write_table = deepcopy(tab)
    if cfg_flags[plugin_name] and cfg_flags[plugin_name].drop_empty_tables then
        remove_empty_tables_rec(write_table)
    end

    succeeded, documentOrErrorMessage = pcall(toml.encodeToFile, write_table, { file = full_path, overwrite = true })
    if not succeeded then
        log.warning(documentOrErrorMessage)
        return nil
    end
    return 0
end

-- Makes sure the config folder exists (Toml can't create it)
local verify_folder = function(plugin_name)
    local full_cfg_path = path.combine(cfg_path, plugin_name)
    local dirs = path.get_directories(cfg_path)
    for _,v in pairs(dirs) do
        if v == full_cfg_path then return "dirExists" end
    end

    local directoryCreated = path.create_directory(full_cfg_path)
    if not directoryCreated then
        log.warning("Couldn't create config folder for " .. plugin_name)
    else 
        log.info("Config folder for "..plugin_name.." successfully created.")
    end
    return directoryCreated
end

local load_cfg = function(plugin_name)
    local full_path = path.combine(cfg_path, plugin_name, cfg_name)
    local succeeded, loaded_table = pcall(toml.decodeFromFile, full_path)
    if not succeeded then
        log.warning("Couldn't find config for "..full_path)
        return nil
    end
    log.info("Config file for "..plugin_name.." successfully loaded")
    return loaded_table
end

-- == Public Functions == --

Toml.save_cfg = function (plugin_name, tab)
    save_buffer[plugin_name] = tab
end

-- Call this at start
Toml.config_update = function(plugin_name, default_table, flags)

    -- Save default params and flags
    cfg_defaults[plugin_name] = deepcopy(default_table)
    if flags ~= nil then
        cfg_flags[plugin_name] = deepcopy(flags)
    end

    local verified = verify_folder(plugin_name)
    if verified == nil then return nil end

    local loaded_table = Toml.load_cfg(plugin_name)
    -- If config doesn't exist, create it
    if not loaded_table then
        save_cfg_internal(plugin_name, default_table)
        return default_table
    end
    -- If it does exist, fill in missing fields  (should we also clean up extra fields? no)
    for k, v in pairs(default_table) do
        if loaded_table[k] == nil then
            log.info("Adding "..k.." field to "..plugin_name.." config") -- weird problem where empty tables get an "added message" every time
            if type(v) == "table" then
                loaded_table[k] = deepcopy(v)
            else
                loaded_table[k] = v
            end    
        end
    end
    save_cfg_internal(plugin_name, loaded_table)
    return loaded_table
end

-- Resets to default table stored in cfg_defaults
Toml.reset_default = function(plugin_name)
    local default_table = cfg_defaults[plugin_name]
    local saved = save_cfg_internal(plugin_name, default_table)
    if saved == nil then
        log.warning("Failed to reset "..plugin_name.." config to default.", 0)
    else
        log.info(plugin_name.." config successfully reset to default.")
    end
    return default_table
end

-- == ImGui == --

-- save cfg once per frame if buffered
gui.add_imgui(function()
    for k, v in pairs(save_buffer) do
        save_cfg_internal(k, v)
        save_buffer[k] = nil
    end
end)

-- == Envy Public Setup == -- 

function public.setup(env)
    if env == nil then
        env = envy.getfenv(2)
    end
    return { ["Toml"] = Toml }
end

function public.auto()
    local env = envy.getfenv(2)
    local wrapper = public.setup(env)
    envy.import_as_shared(env, wrapper)
end

-- == Backward Compatibility == --

public["tomlfuncs"] = true
for k, v in pairs(Toml) do
    public[k] = v
end

-- == End == -- 

log.info("Successfully loaded ".._ENV["!guid"]..".")