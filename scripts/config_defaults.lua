-- config_defaults.lua
--
-- Default configuration settings shared by all or most Conky scripts.
-- Note: Individual scripts allow overrides and customizations.
--
-- Contains all configuration settings listed at 
-- https://conky.cc/config_settings as of 2025-01-25.
-- 
-- Michael Gilchrist (michaelgilch@gmail.com)

-- Create a table to store default config values 
local config = {}

config.defaults = {
	alignment = top_left,  			-- Align Conky on screen (top_left, top_right, etc.)
	-- append_file  						-- Append text/file to Conky's output (no default)
	-- background = true,  				-- If true, Conky forks to background
	border_inner_margin = 0,  	-- Gap between text and inside border
	-- border_outer_margin = 0,  	-- Gap between border and screen edge
	border_width = 0,  				-- Width of the Conky window border
  color0 = 'FFFFFF', 	-- white    (Headings)
  color1 = 'AAAAAA', 	-- grey     (Sub-Headings)
  color2 = '1793D1', 	-- blue     (Values)
  color3 = 'FFC300', 	-- yellow   (Warning)
  color4 = 'FF3300', 	-- red      (Urgent)
  color5 = '999999', 	-- grey     (Graphs)
  color6 = '999999', 	-- grey     (Bars)
	-- color7  					-- User-defined color #7
	-- color8  					-- User-defined color #8
	-- color9  					-- User-defined color #9
	-- console_bar_border  			-- Character(s) used for borders in console-bar mode
	-- console_bar_fill    			-- Character(s) used for fill in console-bar mode
	cpu_avg_samples = 2,  			-- Number of samples to average CPU usage
	default_bar_height = 6,  		-- Default height of bar widgets
	default_bar_width = 0,  		-- Default width of bar widgets (0 = auto)
	default_color = white,  		-- Default text color
	default_gauge_height = 25,  -- Default height of gauge widgets
	default_gauge_width = 40,  	-- Default width of gauge widgets
	default_graph_height = 25,  -- Default height of graph widgets
	default_graph_width = 0,  	-- Default width of graph widgets (0 = auto)
	default_outline_color = '#000000',  -- Default outline color (hex)
	default_shade_color = '#000000',  -- Default shading (shadow) color (hex)
	disable_auto_reload = false,  -- If true, disables auto-reload on config change
	diskio_avg_samples = 2,  -- Number of samples to average disk I/O
	double_buffer = true,  -- Use double buffering to reduce flicker
	draw_borders = false,  -- Draw borders around text area
	draw_graph_borders = true,  -- Draw borders around graphs
	draw_outline = false,  -- Draw outline around text
	draw_shades = true,  -- Draw shaded (shadow) text
	extra_newline = false,  -- Add extra newline at the end of output
	font = 'Monospace',  -- Default font when not using Xft
	format_human_readable = false,  -- If true, show sizes as KiB, MiB, etc.
	gap_x = 10,  -- Horizontal gap from alignment reference
	gap_y = 10,  -- Vertical gap from alignment reference
	-- hddtemp_host = localhost,  -- Host for hddtemp
	-- hddtemp_port = 7634,  -- Port for hddtemp
	-- http_proxy  -- Proxy setting (e.g., http://user:pass@host:port/)
	imlib_cache_flush_interval = 300,  -- Seconds between Imlib2 cache flushes
	imlib_cache_size = 4,  -- Imlib2 cache size in MB
	-- lua_draw_hook_pre   -- Lua function(s) called before Conky draws
	-- lua_draw_hook_post  -- Lua function(s) called after Conky draws
	-- lua_load            -- List of Lua scripts to load
	-- mail_spool  -- Path to mail spool folder
	max_port_monitor_connections = 256,  -- Max connections shown per port
	-- max_special_text_width  -- Special limit on text width (no default)
	max_text_width = 0,  -- Max text width in pixels (0 = unlimited)
	-- maximum_height = 0,  -- Max window height in pixels (0 = none)
	maximum_width = 0,  -- Max window width in pixels (0 = none)
	minimum_height = 0,  -- Min window height
	minimum_width = 0,  -- Min window width
	-- mpd_count  -- Maximum songs fetched from MPD
	mpd_host = localhost,  -- MPD server host
	-- mpd_music_dir  -- Path to MPD music folder
	-- mpd_password   -- MPD server password
	mpd_port = 6600,  -- MPD server port
	-- mpd_retry_interval  -- Seconds between MPD reconnection attempts
	-- mpd_update_interval = 2,  -- Interval (secs) to update MPD stats
	music_player_interval = 5,  -- Interval (secs) for other music players
	net_avg_samples = 2,  -- Number of samples to average net stats
	no_buffers = true,  -- Subtract buffers from used memory
	-- nvidia_display  -- X display to use for NVIDIA stats
	out_to_console = false,  -- Write text to stdout
	out_to_ncurses = false,  -- Use ncurses for text output
	out_to_stderr = false,  -- Write text to stderr
	out_to_x = true,  -- Write to the X window
	override_utf8_locale = false,  -- Force UTF-8
	own_window = true,  -- Create its own window
	own_window_argb_value = 0,  -- ARGB alpha (0–255)
	own_window_argb_visual = false,  -- Use ARGB for real transparency
	own_window_class = 'Conky',  -- Window class name
	own_window_colour = 'black',  -- Window background color
	-- own_window_hints  -- Additional hints (undecorated, sticky, etc.)
	own_window_title = 'conky',  -- Window title
	own_window_transparent = true,  -- Pseudo transparency
	own_window_type = 'desktop',  -- Window type (normal, desktop, dock, etc.)
	pad_percents = 2,  -- Spacing for percentage values
	short_units = false,  -- Use short version of units (KiB->K, etc.)
	show_graph_range = false,  -- Display min/max values on graphs
	show_graph_scale = false,  -- Display scale on graphs
	stippled_borders = 0,  -- Draw borders using a stipple of this size
	-- temperature_unit  -- Force temperature unit (e.g. Celsius, Fahrenheit)
	-- template0  -- Custom template variable
	-- template1  -- Another custom template
	-- template2  -- And so forth...
	text_buffer_size = 256,  -- Size of the text buffer
	times_in_seconds = false,  -- If true, parse $time variables in seconds
	top_cpu_separate = false,  -- Separate CPU usage for top processes
	top_name_width = 15,  -- Width for process names in top
	total_run_times = 0,  -- Number of updates before quitting (0 = infinite)
	-- total_run_times_eval  -- Evaluate times before quitting
	update_interval = 1,  -- Interval (secs) between Conky updates
	update_interval_on_battery = 0,  -- Update interval on battery (0 = disabled)
	uppercase = false,  -- Convert text to uppercase
	use_spacer = none,  -- Add spaces to align text (none, left, or right)
	use_xft = true,  -- Use Xft (anti-aliased fonts)
	-- vsync = false,  -- Enable vsync to reduce tearing
	-- workspaces  -- List of X workspaces for Conky to display
	xftalpha = 1,  -- Alpha for Xft fonts (1 = opaque)
	-- xftfont = 'DejaVu Sans Mono:size=10',  -- Default Xft font
	-- xinerama_head  -- Xinerama monitor index
}

return config