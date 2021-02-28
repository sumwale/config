local awful = require('awful')
local beautiful = require('beautiful')
local wibox = require('wibox')
local TaskList = require('widget.task-list')
local TagList = require('widget.tag-list')
local gears = require('gears')
local clickable_container = require('widget.material.clickable-container')
local mat_icon_button = require('widget.material.icon-button')
local mat_icon = require('widget.material.icon')

local dpi = require('beautiful').xresources.apply_dpi

local icons = require('theme.icons')

local systray = wibox.widget.systray()
systray:set_horizontal(true)
systray:set_base_size(24)

local TopPanel = function(s, offset)
  local offsetx = 0
  if offset == true then
    offsetx = dpi(128)
    offsety = dpi(4)
  end
  local panel =
    wibox(
    {
      ontop = false,
      screen = s,
      height = dpi(24),
      width = dpi(200),
      x = s.geometry.width - dpi(394),
      y = s.geometry.y  + offsety,
      stretch = false,
      bg = beautiful.primary.hue_900,
      fg = beautiful.fg_normal,
      struts = {
        top = dpi(24)
      }
    }
  )

  panel:struts(
    {
      top = dpi(0)
    }
  )

  panel:setup {
      layout = wibox.layout.align.horizontal,
	  wibox.container.margin(systray, dpi(3), dpi(3), dpi(3), dpi(3)),
	  nil,
	  require('widget.battery'),
  }

  return panel
end

return TopPanel
