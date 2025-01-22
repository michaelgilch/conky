-- config_helper.lua
--
-- Helper for Conky configurations, containing functions and settings
-- shared by various Conky .conf files.
-- 
-- Michael Gilchrist (michaelgilch@gmail.com)

-- Create a table to store settings for external use 
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

module.globals = {
    BACKGROUND = false,
    USE_XFT = true,
    FONT = 'Hack:size=8',
    XFTALPHA = 1,

    OWN_WINDOW = true,
    OWN_WINDOW_TYPE = 'desktop',
    OWN_WINDOW_TRANSPARENT = true,

    DOUBLE_BUFFER = true,
    DRAW_SHADES = false,
    DRAW_OUTLINE = false,
    DRAW_BORDERS = false,

    STIPPLED_BORDERS = 0,
    BORDER_WIDTH = 0,
    DRAW_GRAPH_BORDERS = false,

    DEFAULT_COLOR = 'FFFFFF',
    COLOR0 = 'FFFFFF',      -- white    (Headings)
    COLOR1 = 'AAAAAA',      -- grey     (Sub-Headings)
    COLOR2 = '1793D1',      -- blue     (Values)
    COLOR3 = 'FFC300',      -- yellow   (Warning)
    COLOR4 = 'FF3300',      -- red      (Urgent)
    COLOR5 = '999999',      -- grey     (Graphs)
    COLOR6 = '999999',      -- grey     (Bars)
}

return module