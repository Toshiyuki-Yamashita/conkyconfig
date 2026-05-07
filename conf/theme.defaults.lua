-- Shared default appearance values for Conky.
-- Keep portable defaults here, and put machine-specific differences in
-- conf/theme.local.lua or conf/theme.<profile>.lua.

return {
    font = {
        default = {
            family = 'IBM Plex Mono',
            size = 12,
        },
        symbol = {
            family = 'IBM Plex Sans JP',
            size = 8,
        },
    },
    colors = {
        default = 'white',
        outline = 'white',
        shade = 'white',
        label = 'grey',
        process = 'lightgrey',
        graph_background = '000000',
        graph_foreground = 'ffffff',
        load_graph_background = '888888',
        load_graph_foreground = 'FFFFFF',
    },
    layout = {
        border_width = 1,
        gap_x = 30,
        gap_y = 60,
        minimum_height = 5,
        minimum_width = 5,
        graph_height = 20,
        load_graph_width = 120,
        cpu_graph_width = 130,
        fs_bar_height = 6,
    },
    network = {
        interface = 'enp3s0',
    },
    text = {
        temperature_unit = '℃',
        cpu_temperature_unit = 'C',
    },
}
