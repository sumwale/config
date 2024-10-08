local awful = require('awful')
local beautiful = require('beautiful')
local wibox = require('wibox')
local mat_list_item = require('widget.material.list-item')
local mat_icon = require('widget.material.icon')
local dpi = beautiful.xresources.apply_dpi
local icons = require('theme.icons')

return function(_, panel)
  local search_button =
    wibox.widget {
    wibox.widget {
      icon = icons.search,
      size = dpi(24),
      widget = mat_icon
    },
    wibox.widget {
      markup = '<u>S</u>earch <u>A</u>pplications',
      font = 'Cantarell Regular 13',
      widget = wibox.widget.textbox
    },
    clickable = true,
    widget = mat_list_item
  }

  search_button:buttons(
    awful.util.table.join(
      awful.button(
        {},
        1,
        function()
          panel:run_rofi()
        end
      )
    )
  )

  local exit_button =
    wibox.widget {
    wibox.widget {
      icon = icons.logout,
      size = dpi(24),
      widget = mat_icon
    },
    wibox.widget {
      markup = '<u>E</u>nd work session',
      font = 'Cantarell Regular 13',
      widget = wibox.widget.textbox
    },
    clickable = true,
    divider = true,
    widget = mat_list_item
  }

  exit_button:buttons(
    awful.util.table.join(
      awful.button(
        {},
        1,
        function()
          panel:toggle()
          _G.exit_screen_show()
        end
      )
    )
  )

  return wibox.widget {
    layout = wibox.layout.align.vertical,
    {
      layout = wibox.layout.fixed.vertical,
      {
        search_button,
        bg = beautiful.primary.hue_800,
        widget = wibox.container.background
      },
      wibox.widget {
        orientation = 'horizontal',
        forced_height = 0.8,
        opacity = 0.3,
        widget = wibox.widget.separator
      },
      require('layout.left-panel.dashboard.quick-settings'),
      require('layout.left-panel.dashboard.hardware-monitor')
    },
    nil,
    {
      layout = wibox.layout.fixed.vertical,
      {
        exit_button,
        bg = beautiful.primary.hue_800,
        widget = wibox.container.background
      }
    }
  }
end
