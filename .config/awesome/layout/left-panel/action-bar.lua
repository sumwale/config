local awful = require('awful')
local beautiful = require('beautiful')
local wibox = require('wibox')
local gears = require('gears')
local mat_icon = require('widget.material.icon')
local dpi = require('beautiful').xresources.apply_dpi
local icons = require('theme.icons')
local clickable_container = require('widget.material.clickable-container')
local left_panel = require('layout.left-panel')

local menu_widget = function(screen, menu, action_bar_width)
  local menu_icon =
    wibox.widget {
    icon = icons.menu,
    size = dpi(20),
    widget = mat_icon,
  }

  local home_button =
    wibox.widget {
    wibox.widget {
      menu_icon,
      widget = clickable_container
    },
    visible = true,
    --bg = beautiful.primary.hue_500,
    widget = wibox.container.background
  }

  local panel = left_panel(screen)

  home_button:buttons(
    awful.util.table.join(
      awful.button(
        {},
        1,
        function()
          panel:toggle()
        end
      )
    )
  )

  panel:connect_signal(
    'opened',
    function()
      -- menu_icon.icon = icons.close
      menu.ontop = true
      menu.bg = beautiful.primary.hue_600
    end
  )

  panel:connect_signal(
    'closed',
    function()
      -- menu_icon.icon = icons.menu
      menu.ontop = false
      menu.bg = beautiful.primary.hue_500
    end
  )

  return wibox.widget {
    id = 'action_bar',
    layout = wibox.layout.align.horizontal,
    forced_width = action_bar_width,
    {
      layout = wibox.layout.fixed.horizontal,
      home_button,
    }
  }
end

local menu_button = function(screen)
   local action_bar_width = dpi(24)

  local menu =
    wibox {
    screen = screen,
    width = dpi(24),
    height = dpi(24),
    x = screen.geometry.x + dpi(12),
    y = screen.geometry.y + dpi(4),
    ontop = false,
    bg = beautiful.primary.hue_500,
    fg = beautiful.fg_normal
  }

  menu:struts(
    {
      left = dpi(0)
    }
  )

  menu:setup {
    layout = wibox.layout.align.horizontal,
    menu_widget(screen, menu, action_bar_width)
  }
  return menu
end

return menu_button
