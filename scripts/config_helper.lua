-- config_helper.lua
--
-- Helper for Conky configurations, containing functions 
-- shared by various Conky .conf files.
-- 
-- Michael Gilchrist (michaelgilch@gmail.com)

-- Create a table to store functions for external use 
local module = {}

-- get_hostname()
-- @return String containing system hostname
function module.get_hostname()
    local file = io.open("/proc/sys/kernel/hostname", "r")
    local hostname = file and file:read("*l") or "unknown"
    
    if file then 
        file:close() 
    end
    
    return hostname
end

-- get_resolution()
-- Uses xrandr to obtain the current resolution of the display.
-- @return String representation of the resolution
function module.get_resolution()
    local handle = io.popen("xrandr | grep '*' | awk '{print $1}' | head -n1")
    if not handle then
        return nil
    end

    -- Read the resolution (something like "1920x1080\n")
    local resolution = handle:read("*a")
    handle:close()

    -- Strip trailing whitespace
    resolution = resolution and resolution:gsub("%s+", "")

    return resolution
end

-- merge_tables(t1, t2)
-- Helper function to merge two tables, adding and overwriting
-- entries in t1 with those from t2. 
-- @return Single merged table
function module.merge_tables(t1, t2)
    local merged = {}
    for k, v in pairs(t1) do
        merged[k] = v
    end
    for k, v in pairs(t2) do
        merged[k] = v
    end
    return merged
end

function module.print_merged_config_table(t)
    for k, v in pairs(t) do
        print(k, v)
    end
end

return module