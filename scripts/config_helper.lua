-- config_helper.lua
--
-- Helper for Conky configurations, containing functions and settings
-- shared by various Conky .conf files.
-- 
-- Michael Gilchrist (michaelgilch@gmail.com)

-- Create a table to store settings for external use 
local module = {}

-- get_resolution()
-- Uses xrandr to obtain the current resolution of the display.
--
-- @return String representation of the resolution
function module.get_hostname()
    local file = io.open("/proc/sys/kernel/hostname", "r")
    local hostname = file and file:read("*l") or "unknown"
    
    if file then 
        file:close() 
    end
    
    return hostname
end

-- get_hostname()
-- Gets the system Hostname.
--
-- @return String containing hostname
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

-- Default settings
module.defaults = {
    GAP_X = 25,
    GAP_Y = 50,
    MINIMUM_WIDTH = 300,
    MAXIMUM_WIDTH = 300,
    FONT = 'Hack:size=8'
}

return module