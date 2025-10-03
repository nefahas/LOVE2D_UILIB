-- structuring:
--[[
    on .new constructor within ui.main:
        create a "scene" which holds all ui objects
        this is within an actual LOVE canvas
]]

local VALID_OBJECT_TYPES = {
    'frame',
    'button'
}

local BASE_OBJECT_MT = require('ui.object')
local OBJ_TEMPLATE = require('ui.templateObject')

local scene = {}
scene.__index = scene

local function CLEAR_CANVAS()
    love.graphics.clear(0, 0, 0, 1)
end

function table.find(tbl, a)
    for i, v in pairs(tbl) do
        if v == a then
            return i
        end
    end
end

function scene:close()
    for i, v in pairs(self.objects) do
        v:destroy()
        table.remove(self.objects, i)
    end

    if self.canvas then
        self.canvas:release()
        self.canvas = nil
    end
end

function scene:draw()
    local canvas = self.canvas
    
    table.sort(self.objects, function(a, b)
        return a.zIndex < b.zIndex
    end)

    local hasAnyUpdate = false

    for i, v in pairs(self.objects) do
        if not v.rendered then
            hasAnyUpdate = true
            break
        end
    end

    if hasAnyUpdate then
        hasAnyUpdate = false

        for i, v in pairs(self.objects) do
            v.rendered = false
        end
        
        canvas:renderTo(CLEAR_CANVAS)
    end

    for i, v in pairs(self.objects) do
        if not v.rendered then
            v.rendered = true
            canvas:renderTo(v.draw, v)
        end
    end

    love.graphics.draw(self.canvas)
end

function scene:newObject(objectType, data)
    assert(type(data) == 'table', 'data passed to newObject must be of type TABLE')

    if data.parent and type(data.parent) ~= 'table' then
        error('data.parent is of invalid type, not ui object')
    end

    local t = {
        type = objectType
    }

    for i, v in pairs(OBJ_TEMPLATE) do
        if not t[i] then
            t[i] = data[i] or v
        end
    end

    local new = setmetatable(t,  {
        __index = BASE_OBJECT_MT,
        __newindex = function(self, k, v)
            if rawget(self, k) ~= nil then
                rawset(self, 'rendered', false)

                rawset(self, k, v)
            else
                error(string.format('attempt to set invalid property %s to %s', k, v))
            end
        end
    })

    new:init()
    
    table.insert(self.objects, new)

    return new
end

function scene:update(dt)
    local mx, my = love.mouse.getPosition()
    local objects = self:getObjectsAtPosition(mx, my)

    for i, obj in pairs(self.objects) do
        if obj.type == 'button' or obj.onHover then
            local mouseInside = table.find(objects, obj) and true or false
            local o = obj.mouseInside

            rawset(obj, 'mouseInside', mouseInside)

            if o ~= mouseInside then
                rawset(obj, 'rendered', false)
            end
        end
    end
end

function scene:getObjectsAtPosition(x, y)
    local inside = {}

    for i, obj in pairs(self.objects) do
        local absX = obj.absoluteX
        local absY = obj.absoluteY

        local absWidth = obj.absoluteWidth
        local absHeight = obj.absoluteHeight

        local inWidth = (x >= absX and x <= absX + absWidth)
        local inHeight = (y >= absY and y <= absY + absHeight)

        if (inWidth and inHeight) then
            table.insert(inside, obj)
        end
    end

    return inside
end

function scene:mouseClick(x, y, button)
    local objects = self:getObjectsAtPosition(x, y)

    if #objects > 0 then
        for i, v in pairs(objects) do
            local m1Func = type(v.onClick) == 'function' and v.onClick or nil
            
            if button == 1 and m1Func then
                local thread = coroutine.create(m1Func)
                
                coroutine.resume(thread, v, x, y)
            end
        end
    end
end

function scene:mouseRelease(x, y, button)
    local objects = self:getObjectsAtPosition(x, y)

    if #objects > 0 then
        for i, v in pairs(objects) do
            local m1Func = type(v.onClickRelease) == 'function' and v.onClickRelease or nil
            
            if button == 1 and m1Func then
                local thread = coroutine.create(m1Func)
                
                coroutine.resume(thread, v, x, y)
            end
        end
    end
end

function scene.new(width, height)
    width = type(width) == 'number' and width or love.graphics.getWidth()
    height = type(height) == 'number' and height or love.graphics.getHeight()

    local self = setmetatable({
        objects = {},
        canvas = love.graphics.newCanvas(width, height),
        width = width,
        height = height,
    }, scene)

    return self
end

return scene
