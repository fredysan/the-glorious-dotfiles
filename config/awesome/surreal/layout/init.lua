local awful = require('awful')
local top_panel = require('layout.top-panel')
local bottom_panel = require('layout.bottom-panel')
local control_center = require('layout.control-center')
local info_center = require('layout.info-center')
-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
-- Declarative object management
local ruled = require("ruled")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")



-- Create a wibox panel for each screen and add it
screen.connect_signal(
	'request::desktop_decoration',
	function(s)
    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()

    -- Create an imagebox widget which will contain an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox {
        screen  = s,
        buttons = {
            awful.button({ }, 1, function () awful.layout.inc( 1) end),
            awful.button({ }, 3, function () awful.layout.inc(-1) end),
            awful.button({ }, 4, function () awful.layout.inc(-1) end),
            awful.button({ }, 5, function () awful.layout.inc( 1) end),
        }
    }

    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist {
        screen  = s,
        filter  = awful.widget.taglist.filter.all,
        buttons = {
            awful.button({ }, 1, function(t) t:view_only() end),
            awful.button({ modkey }, 1, function(t)
                                            if client.focus then
                                                client.focus:move_to_tag(t)
                                            end
                                        end),
            awful.button({ }, 3, awful.tag.viewtoggle),
            awful.button({ modkey }, 3, function(t)
                                            if client.focus then
                                                client.focus:toggle_tag(t)
                                            end
                                        end),
            awful.button({ }, 4, function(t) awful.tag.viewprev(t.screen) end),
            awful.button({ }, 5, function(t) awful.tag.viewnext(t.screen) end),
        }
    }

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist {
        screen  = s,
        filter  = awful.widget.tasklist.filter.currenttags,
        buttons = {
            awful.button({ }, 1, function (c)
                c:activate { context = "tasklist", action = "toggle_minimization" }
            end),
            awful.button({ }, 3, function() awful.menu.client_list { theme = { width = 250 } } end),
            awful.button({ }, 4, function() awful.client.focus.byidx(-1) end),
            awful.button({ }, 5, function() awful.client.focus.byidx( 1) end),
        }
    }


    s.textclock = wibox.widget.textclock('<span font="Roboto Mono 10">%I:%M %p</span>')
    -- s.clock_widget = wibox.container.margin(textclock, dpi(13), dpi(13), dpi(9), dpi(8))

    -- Create the wibox
    s.mywibox = awful.wibar({ position = "top", screen = s })

    -- Add widgets to the wibox
    s.mywibox.widget = {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            s.mytaglist,
            s.mypromptbox,
        },
        s.mytasklist, -- Middle widget
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            mykeyboardlayout,
            wibox.widget.systray(),
            s.textclock,
            s.mylayoutbox,
        },
    }
		-- s.top_panel = top_panel(s)
		-- s.bottom_panel = bottom_panel(s)
		-- s.control_center = control_center(s)
		-- s.info_center = info_center(s)
		-- s.control_center_show_again = false
		-- s.info_center_show_again = false
	end
)

-- Hide bars when app go fullscreen
function update_bars_visibility()
	for s in screen do
		if s.selected_tag then
			local fullscreen = s.selected_tag.fullscreen_mode
			-- Order matter here for shadow
			-- s.top_panel.visible = not fullscreen
			-- s.bottom_panel.visible = not fullscreen
			-- if s.control_center then
			-- 	if fullscreen and s.control_center.visible then
			-- 		s.control_center:toggle()
			-- 		s.control_center_show_again = true
			-- 	elseif not fullscreen and not s.control_center.visible and s.control_center_show_again then
			-- 		s.control_center:toggle()
			-- 		s.control_center_show_again = false
			-- 	end
			-- end
			-- if s.info_center then
			-- 	if fullscreen and s.info_center.visible then
			-- 		s.info_center:toggle()
			-- 		s.info_center_show_again = true
			-- 	elseif not fullscreen and not s.info_center.visible and s.info_center_show_again then
			-- 		s.info_center:toggle()
			-- 		s.info_center_show_again = false
			-- 	end
			-- end
		end
	end
end

tag.connect_signal(
	'property::selected',
	function(t)
		update_bars_visibility()
	end
)

client.connect_signal(
	'property::fullscreen',
	function(c)
		if c.first_tag then
			c.first_tag.fullscreen_mode = c.fullscreen
		end
		update_bars_visibility()
	end
)

client.connect_signal(
	'unmanage',
	function(c)
		if c.fullscreen then
			c.screen.selected_tag.fullscreen_mode = false
			update_bars_visibility()
		end
	end
)
