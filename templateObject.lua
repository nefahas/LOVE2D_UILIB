local template = {
        width = {0, 100},
        height = {0, 100},
        x = {0, 0},
        y = {0, 0},
        anchorX = 0,
        anchorY = 0,
        scene = false,
        type = '',
        parent = false,
        zIndex = 0,
        color = {r = 1, g = 1, b = 1, a = 1},
        border = false,
        borderColor = {r = 0, g = 0, b = 0},

        rendered = false,

        absoluteX = 0,
        absoluteY = 0,
        absoluteWidth = 0,
        absoluteHeight = 0,

        text = '',
        textSize = 14,
        textColor = {r = 0, g = 0, b = 0, a = 1},
        textHorizontalAlign = 'center',
        textVerticalAlign = 'center',

        onClick = false,
        onHover = false,
}

return template