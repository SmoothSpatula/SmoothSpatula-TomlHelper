-- Toml-helper v1.0.1
-- SmoothSpatula

log.info("Successfully loaded ".._ENV["!guid"]..".")

-- ========== Data ==========

tomlfuncs = true

local self = {}
local cfg_path = path.get_parent(_ENV["!config_mod_folder_path"])
local cfg_name = "cfg.toml"


-- ========== Functions ==========

load_cfg = function(plugin_name)
    local full_path = path.combine(cfg_path, plugin_name, cfg_name)
    local succeeded, loaded_table = pcall(toml.decodeFromFile, full_path)
    if not succeeded then
        print("Error loading "..full_path)
        return nil
    end
    log.info("Config file for "..plugin_name.." successfully loaded")
    return loaded_table
end

save_cfg = function (plugin_name, table)
    if verify_folder(plugin_name) == nil then return nil end
    local full_path = path.combine(cfg_path, plugin_name, cfg_name)
    succeeded, documentOrErrorMessage = pcall(toml.encodeToFile, table, { file = full_path, overwrite = true })
    if not succeeded then
        print(documentOrErrorMessage)
        return nil
    end
    return 0
end

-- Makes sure the config folder exists (Toml can't create it)
verify_folder = function(plugin_name)

    local full_cfg_path = path.combine(cfg_path, plugin_name)
    local dirs = path.get_directories(cfg_path)
    for _,v in pairs(dirs) do
        if v == full_cfg_path then return 0 end
    end

    directoryCreated = path.create_directory(full_cfg_path)
    if not directoryCreated then
        print("Couldn't create config folder for " .. plugin_name)
        return nil
    end
    return 0
end

-- Call this
config_update = function(plugin_name, default_table)
    local loaded_table = load_cfg(plugin_name)
    -- If config doesn't exist, create it
    if not loaded_table then
        save_cfg(plugin_name, default_table)
        return default_table
    end
    -- If it does exist, fill in missing fields  (should we also clean up extra fields?)
    for k, v in pairs(default_table) do
        if loaded_table[k] == nil then
            print("Adding "..k.." field to "..plugin_name.." config")
            loaded_table[k] = v
        end
    end
    save_cfg(plugin_name, loaded_table)
    return loaded_table
end
    save_cfg(plugin_path, loaded_table)
    return loaded_table
end
