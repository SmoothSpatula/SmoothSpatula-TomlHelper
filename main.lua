-- Toml-helper v1.0.0
-- SmoothSpatula

log.info("Successfully loaded ".._ENV["!guid"]..".")

-- ========== Data ==========

tomlfuncs = true

local self = {}
local cfg_path = "ReturnOfModding/config"
local cfg_name = "cfg.toml"
local full_cfg_path = path.get_parent(path.get_parent(_ENV["!plugins_mod_folder_path"]))

-- ========== Functions ==========

load_cfg = function(plugin_path)
    local full_path = path.combine(cfg_path, plugin_path, cfg_name)
    local succeeded, loaded_table = pcall(toml.decodeFromFile, full_path)
    if not succeeded then
        print("Error loading "..full_path)
        return nil
    end
    log.info("config file successfully loaded")
    return loaded_table
end

save_cfg = function (plugin_path, table)
    verify_folder(plugin_path)
    local full_path = path.combine(cfg_path, plugin_path, cfg_name)
    succeeded, documentOrErrorMessage = pcall(toml.encodeToFile, table, { file = full_path, overwrite = true })
    if not succeeded then
        print(documentOrErrorMessage)
        return nil
    end
    return 0
end

-- Makes sure the config folder exists (Toml can't create it)
verify_folder = function(plugin_path)
    local create_dir_path = path.combine(full_cfg_path, "config", plugin_path)
    if gm.directory_exists(create_dir_path) ==.0 then
        log.info("Creating config directory")
        gm.directory_create(create_dir_path)
    end
end

-- Call this
config_update = function(plugin_path, default_table)
    local loaded_table = load_cfg(plugin_path)
    -- If config doesn't exist, create it
    if not loaded_table then
        save_cfg(plugin_path, default_table)
        return default_table
    end
    -- If it does exist, fill in missing fields  (should we also clean up extra fields?)
    for k, v in pairs(default_table) do
        if loaded_table[k] == nil then
            print("Adding "..k.." field to "..plugin_path.." config")
            loaded_table[k] = v
        end
    end
    save_cfg(plugin_path, loaded_table)
    return loaded_table
end
