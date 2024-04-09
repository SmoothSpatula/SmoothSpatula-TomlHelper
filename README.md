# SmoothSpatula-TomlHelper

Helper mod for saving and loading Toml config files for SmoothSpatula mods.

### Usage example

* Initializing and loading the config
```
mods.on_all_mods_loaded(function() for k, v in pairs(mods) do if type(v) == "table" and v.tomlfuncs then Toml = v end end 
    params = {
        max_number = 4,
        enabled = true
    }
    params = Toml.config_update(_ENV["!guid"], params) -- Load Save
end)
```

* Saving the config
```
Toml.save_cfg(_ENV["!guid"], params)
```
