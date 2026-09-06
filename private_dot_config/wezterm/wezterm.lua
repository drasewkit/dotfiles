local wezterm = require 'wezterm'
local config = wezterm.config_builder()

config.automatically_reload_config = true
config.font_size = 16.0
config.use_ime = true
config.window_background_opacity = 0.85
config.macos_window_background_blur = 20

-- タイトルバーを非表示にする
config.window_decorations = "RESIZE"

-- タブバーの表示
config.show_tabs_in_tab_bar = true

-- タブバーの背景を透明にする
config.window_frame = {
    inactive_titlebar_bg = "none",
    active_titlebar_bg = "none",
}

config.use_fancy_tab_bar= true

config.window_frame = {
    inactive_titlebar_bg = "none",
    active_titlebar_bg = "none",
}

config.window_background_gradient = {
    colors = { "#000000" },
}

-- タブバーの新しいタブボタンを非表示にする
config.show_new_tab_button_in_tab_bar = false

-- タブバーの閉じるボタンを非表示にする
config.show_close_tab_button_in_tabs = false

config.colors = {
    tab_bar = {
        inactive_tab_edge = "none",
    },
}

-- タブの形をカスタマイズ
-- タブの左側の装飾
local SOLID_LEFT_ARROW = wezterm.nerdfonts.ple_lower_right_triangle
-- タブの右側の装飾
local SOLID_RIGHT_ARROW = wezterm.nerdfonts.ple_upper_left_triangle

-- タブのタイトルをカスタマイズする
wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
    local background = "#5c6d74"
    local foreground = "#FFFFFF"
    local edge_background = "none"

    if tab.is_active then
        background = "#8a2be2"
        foreground = "#FFFFFF"
    end

    local edge_foreground = background

    local title = "   " .. wezterm.truncate_right(tab.active_pane.title, max_width - 1) .. "   "

    return {
        { Background = { Color = edge_background } },
        { Foreground = { Color = edge_foreground } },
        { Text = SOLID_LEFT_ARROW },
        { Background = { Color = background } },
        { Foreground = { Color = foreground } },
        { Text = title },
        { Background = { Color = edge_background } },
        { Foreground = { Color = edge_foreground } },
        { Text = SOLID_RIGHT_ARROW },
    }
end)

config.default_cursor_style = "SteadyBar"

config.font = wezterm.font_with_fallback({
    {
        family = "JetBrainsMono Nerd Font",
        harfbuzz_features = { "zero" },
    },
    "Hiragino Sans",
    "Apple Color Emoji",
})

return config