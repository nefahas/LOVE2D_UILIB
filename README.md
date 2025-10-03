**documentation:**


**ui_scene**

    constructor .new(width: number?, height: number?) -> ui_scene
    ui_scene:update(dt: number) -> () -- does update check for mouse inside objects, whatever you want to add to it etc
    ui_scene:getObjectsAtPosition(x: number, y: number) -> {object} -- returns an array of objects whose bounds occupy x, y
    ui_scene:mouseClick(x: number, y: number, button: number) -> () -- handles mouse clicking at x, y for objects with a binded mouse click function
    ui_scene:mouseRelease(x: number, y: number, button: number) -> () -- the same as above, but mouse release

    ui_scene:newObject(objectType: string, data: {[string]: any}) -> object -- creates an object usiong data or a template value for data, valid types are "frame" and "button"

    ui_scene:close() -> () -- deconstructor

**object**

all these are internal functions, handled by the library, but the user is allowed to call them aswell

    object:renderText() -> () -- draws text defined at self.text
    object:draw() -> () -- renders the object, calls :renderText() if necessary

    object:init() -> () -- initializes object


**OBJECT PROPERTIES ALLOWED WITHIN newObject DATA ARGUMENT**
**SCALE AND OFFSET ARE BOTH NUMBERS, WHERE SCALE IS 0-1, MULTIPLY OF PARENT SIZE, AND OFFSET IS PIXELS 1-INF**

example: say that position x of an object is {1, 0}, the object would be at the right side of the screen

this also applies to anchorX and anchorY, where 0-1 is the norm, and the position is offset by the anchor * size axis related

x {1, 0} | anchorX = 1

the object would be on the right, but the rightside of object would be touching the right end of the parent (screen or object)

    
        width: {scale, offset}
        height: {scale, offset}
        x: {scale, offset}
        y: {scale, offset}
        anchorX: number 0-1
        anchorY: number 0-1
        type: string "button" or "frame"
        parent: object | nil (if parented to object, all scales will be multiplied by parent relative size or position, else by screen)
        zIndex: number (display order, highest displayed first)
        color: {r: number, g: number, b: number, a: number}, def {r = 1, g = 1, b = 1, a = 1}
        border: boolean -- if true, make a border
        borderColor: {r: number, g: number, b: number, a: number} -- used by :draw to render border color, not necessary  |  def {r = 0, g = 0, b = 0, a = 1}

  ** most are internal, but can still be set or called externally, and are particularly useful in the case of absoluteProp**
        
        rendered = false, -- internal property to call :draw when changes are registered

        absoluteX: number -- also internal, gets the actual rendered pixel position X of object
        absoluteY: number -- internal, gets actual rendered pixel position Y of object
        absoluteWidth: number -- internal, gets actual rendered width
        absoluteHeight: number -- internal, gets actual rendered height

        text: string -- if textLen > 0 (aka set), will render text based on below properties
        textSize: number -- font size
        textColor: {r: number, g: number, b: number, a: number}  -- text color, def {r = 0, g = 0, b = 0, a = 1}
        textHorizontalAlign: string -- allows 'left' 'center' 'right'
        textVerticalAlign: string -- allows 'top' 'center' 'bottom'

        onClick: function -- if a function is defined for this, will get called with (x: number, y: number, button: number) on any mouse click


** usage example**

        UI_LIB = require('ui.main')
        UI_SCENE = UI_LIB.new()
        
        -- love handles
        
        function love.draw()
            UI_SCENE:draw()
        end
        
        function love.mousepressed(x, y, button)
            UI_SCENE:mouseClick(x, y, button)
        end
        
        function love.mousereleased(x, y, button)
            UI_SCENE:mouseRelease(x, y, button)
        end
        
        function love.update(dt)
            GAME_LIB:update(dt)
        end
