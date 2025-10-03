local DEFAULT_TEXT_COLOR = {r = 0, g = 0, b = 0, a = 1}

-- indexed by size
local font_cache = {}

local object = {}

local function HandleScalePos(n, pSize)
    if n > 1 or n < 0 then
        return n
    end

    return n * pSize
end

function object:renderText()
    local text = self.text
    local absX, absY, absW, absH = self.absoluteX, self.absoluteY, self.absoluteWidth, self.absoluteHeight
    local textAlignW = self.textHorizontalAlign or 'center'
    local textAlignH = self.textVerticalAlign or 'center'
    local textColor = self.textColor or DEFAULT_TEXT_COLOR

    if not text or not absX or not absY or not absW or not absH then
        return
    end

    local font

    if not self.font then
        local textSize = self.textSize

        font = font_cache[textSize]

        if not font then
            font = love.graphics.newFont(textSize)
            font_cache[textSize] = font
        end
    end

    local midX, midY = math.floor((absX + absW / 2)), math.floor((absY + absH / 2)) -- this is frame center, we have to minus the offset from the font next
    local width = font:getWidth(text)
    local height = font:getHeight()

    local drawX, drawY

    -- alignments ;=;
    if textAlignW == 'center' then
        drawX = midX - width / 2
    elseif textAlignW == 'left' then
        drawX = absX
    elseif textAlignW == 'right' then
        drawX = absX + absW - width
    end

    if textAlignH == 'center' then
        drawY = midY - height / 2
    elseif textAlignH == 'top' then
        drawY = absY
    elseif textAlignH == 'bottom' then
        drawY = absY + absH - height
    end
    
    drawX = math.floor(drawX)
    drawY = math.floor(drawY)

    love.graphics.setColor(textColor.r, textColor.g, textColor.b, textColor.a)

    local curOffset = 0

    for i = 1, #text do
        local ch = string.sub(text, i, i)

        love.graphics.print(ch, font, drawX + curOffset, drawY)
        
        if i + 1 <= #text then
            local nxt = string.sub(text, i + 1, i + 1)
            local w = font:getWidth(ch)
            local k = font:getKerning(ch, nxt)

            curOffset = curOffset + w + k
        end
    end
end

function object:draw()
    local SCREEN_WIDTH, SCREEN_HEIGHT = love.graphics.getWidth(), love.graphics.getHeight()

    local parent = self.parent
    local width, height = self.width, self.height
    local x, y = self.x, self.y
    
    local wScale, wPx = width[1], width[2]
    local hScale, hPx = height[1], height[2]
    local xScale, xPx = x[1], x[2]
    local yScale, yPx = y[1], y[2]
    
    -- normalize scales into pixel coordinates

    wPx = wPx + math.floor(HandleScalePos(wScale, parent and parent.absoluteWidth or SCREEN_WIDTH))
    hPx = hPx + math.floor(HandleScalePos(hScale, parent and parent.absoluteHeight or SCREEN_HEIGHT))
    
    xPx = xPx + math.floor(HandleScalePos(xScale, parent and parent.absoluteWidth or SCREEN_WIDTH))
    yPx = yPx + math.floor(HandleScalePos(yScale, parent and parent.absoluteHeight or SCREEN_HEIGHT))
    
    local xPxOffset = wPx * self.anchorX
    local yPxOffset = hPx * self.anchorY

    local r = self.color.r
    local g = self.color.g
    local b = self.color.b
    local a = self.color.a

    local OR, OG, OB, OA = love.graphics.getColor()
    
    xPx, yPx = xPx - xPxOffset, yPx - yPxOffset
    
    if self.type == 'button' and type(self.onHover) ~= 'function' and self.mouseInside then
        r, g, b = math.max(r - 0.2, 0), math.max(g - 0.2, 0), math.max(b - 0.2, 0)
    end

    love.graphics.setColor(r, g, b, a)
    love.graphics.rectangle('fill', xPx, yPx, wPx, hPx)
    love.graphics.setColor(OR, OG, OB, OA)

    rawset(self, 'absoluteX', xPx)
    rawset(self, 'absoluteY', yPx)
    rawset(self, 'absoluteWidth', wPx)
    rawset(self, 'absoluteHeight', hPx)

    if string.len(self.text) > 0 then
        self:renderText()

        love.graphics.setColor(OR, OG, OB, OA)
    end

    if self.border and self.borderColor then
        local br, bg, bb, ba = self.borderColor.r, self.borderColor.g, self.borderColor.b, self.borderColor.a

        love.graphics.setColor(br, bg, bb, ba)
        love.graphics.rectangle('line', xPx, yPx, wPx, hPx)
        love.graphics.setColor(OR, OG, OB, OA)
    end
end

function object:init()
    if self.parent then
        local z = self.parent.zIndex

        self.zIndex = z + self.zIndex
    end
end

return object