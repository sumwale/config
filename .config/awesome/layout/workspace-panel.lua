local awful = require('awful')
local beautiful = require('beautiful')
local wibox = require('wibox')
local TagList = require('widget.tag-list')

local dpi = require('beautiful').xresources.apply_dpi

local WorkspacePanel = function(s, offset)
  --local offsetx = 0
  --local offsety = 0
  local offsetx = dpi(5)
  local offsety = dpi(32)
  --if offset == true then
  --  offsetx = dpi(5)
  --  offsety = dpi(32)
  --end
  local panel =
    wibox(
    {
      ontop = false,
      screen = s,
      height = dpi(164),
      width = dpi(23),
      x = s.geometry.x + offsetx,
      y = s.geometry.y + offsety,
      stretch = false,
      bg = beautiful.primary.hue_900,
      fg = beautiful.fg_normal,
      opacity = 0.75,
      struts = {
        left = dpi(24)
      }
    }
  )

  panel:struts(
    {
      left = dpi(0)
    }
  )

  panel:setup {
      layout = wibox.layout.align.vertical,
      TagList(s)
  }

  return panel
end

return WorkspacePanel
