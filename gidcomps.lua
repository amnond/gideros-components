--[[
This code is MIT licensed, see https://opensource.org/licenses/MIT
Copyright 2018 Amnon David
]]

-----------------------------------------------------------------------------
function table_dumps(tbl)
    if not tbl then
        return 'nil'
    end
    local str = ''
    for k, v in pairs(tbl) do
        str = str .. k .. ": "
        if type(v) == "table" then
            str = str .. dumpst(v)
        else
            str = str ..(v)
        end
        str = str .. ' '
    end
    return str
end

-----------------------------------------------------------------------------
function RButton(text, ax, ay, w, h, params)
    local f = 0.42
    local linew = 2
    local fillc = 'ffff44'
    local linec = '000000'
    local textc = '000000'
    local focus_fillc = '2222aa'
    local focus_linec = 'aaffaa'
    local focus_textc = 'aaffaa'
    local font_file = nil
    local priv = {}

       priv.str2col = function(str)
        local def = '000000'
        if not str then
            str = def
        end
        
        if #str ~= 6 then
            str = def
        end
        
        local res = tonumber(str, 16)
        if not res then
            res = tonumber(def, 16)
        end
        return res
    end
    
    if params then
        f = f or params.roundness
        linew = linew or params.line_width
        fillc = fillc or params.fill_color
        linec = linec or params.line_color
        textc = textc or params.text_color
        focus_fillc = focus_fillc or params.focus_fill_color
        focus_linec = focus_linec or params.focus_line_color
        focus_textc = focus_textc or params.focus_text_color
        font_file = params.font_file
    end

    local fill_color = priv.str2col(fillc)
    local line_color = priv.str2col(linec) 
    local text_color = priv.str2col(textc)
    local focus_fillcol = priv.str2col(focus_fillc)
    local focus_linecol = priv.str2col(focus_linec)
    local focus_textcol = priv.str2col(focus_textc)

    local focus = false 
    local textfield = nil
    
    local handler = nil
    local context = nil
    
    local myShape = Shape.new()

    priv.drawButton = function(fc, lc)
        myShape:clear()
        myShape:setFillStyle(Shape.SOLID, fc)
        myShape:setLineStyle(linew, lc)
        myShape:beginPath()
        local r = f*h/2
        local r1x = ax + w/2 - r
        local r1y = ay - h/2 + r
        local step = math.pi / 52
        myShape:moveTo(r1x,r1y-r)
        for a = -math.pi/2, 0, step do
            local x = r1x + r * math.cos(a)
            local y = r1y + r * math.sin(a)
            myShape:lineTo(x,y)
        end

        local r2x = ax + w/2 - r
        local r2y = ay + h/2 - r
        myShape:lineTo(r2x+r,r2y)
        for a = 0, math.pi/2, step do
            local x = r2x + r * math.cos(a)
            local y = r2y + r * math.sin(a)
            myShape:lineTo(x,y)
        end

        local r3x = ax - w/2 + r
        local r3y = ay + h/2 - r
        myShape:lineTo(r3x,r3y+r)
        for a = math.pi/2, math.pi, step do
            local x = r3x + r * math.cos(a)
            local y = r3y + r * math.sin(a)
            myShape:lineTo(x,y)
        end

        local r4x = ax - w/2 + r
        local r4y = ay - h/2 + r
        myShape:lineTo(r4x-r,r4y)
        for a = math.pi, math.pi*1.5, step do
            local x = r4x + r * math.cos(a)
            local y = r4y + r * math.sin(a)
            myShape:lineTo(x,y)
        end

        myShape:lineTo(r1x,r1y-r)
        myShape:endPath()
    end

    priv.drawButton(fill_color, line_color)
    
    local font_size = 8
    local padding = 0.08*w -- Make total x-padding 8 percent of width
    local padx = 0
    local pady = 0
    local save_lineh = 0

    while font_size < 60 do
        local font = TTFont.new(font_file, font_size)
        local tf = TextField.new(font, text)
        local lineh = tf:getHeight()
        local linew = tf:getWidth()
        if lineh > h-padding or linew > w-padding then
            break
        end
        padx = w - linew
        pady = h - lineh
        save_lineh = lineh
        font_size = font_size + 1       
    end
    -- TTFont.new exhausts open file handles before garbage is collected resulting in 
    -- errors of type: "Vera.ttf: No such file or directory.", a message which has little
    -- relation to the actual problem...
    collectgarbage("collect") 
    
    font_size = font_size - 1
    
    myShape.drawText = function()
        local whichcol = text_color
        if focus then
            whichcol = focus_textcol
        end
        
        if textfield then
            myShape:removeChild(textfield)
        end
    
        local font = TTFont.new(font_file, font_size)
        textfield = TextField.new(font, text)
        myShape:addChild(textfield)
        textfield:setTextColor(whichcol)    
        textfield:setPosition(ax-w/2+padx/2, ay+save_lineh/2)
    end
    
    myShape.getFontSize = function()
        return font_size
    end

    myShape.updateFocusColors = function()
        if focus then
            priv.drawButton(focus_fillcol, focus_linecol)
        else
            priv.drawButton(fill_color, line_color)
        end
        myShape.drawText()
    end
    
    myShape.setFontSize = function(size)
        local font = TTFont.new(font_file, size)
        local tf = TextField.new(font, text)
        local lineh = tf:getHeight()
        local linew = tf:getWidth()
        if lineh > h-padding or linew > w-padding then
            print("Font too large")
            return false
        end
        padx = w - linew
        pady = h - lineh
        save_lineh = lineh
        font_size = size        
    end

    myShape.setHandler = function( func, ctx )
        if type(func) ~= "function" then
            return
        end
        handler = func
        context = ctx
    end
    
    function myShape:onMouseDown(event)
        if myShape:hitTestPoint(event.x, event.y) then
            focus = true
            myShape.updateFocusColors()
            event:stopPropagation()
        end
    end

    function myShape:onMouseUp(event)
        if not focus then
            return
        end

        if myShape:hitTestPoint(event.x, event.y) then
            focus = false
            myShape.updateFocusColors()
            if handler then
                handler(context)
            end
            event:stopPropagation()
        end
    end

    function myShape:onMouseMove(event)
        if not focus then
            return
        end
        
        if not myShape:hitTestPoint(event.x, event.y) then
            focus = false
            myShape.updateFocusColors()         
        end
        event:stopPropagation()
    end
    
    myShape:addEventListener(Event.MOUSE_DOWN, myShape.onMouseDown, myShape)
    myShape:addEventListener(Event.MOUSE_MOVE, myShape.onMouseMove, myShape)
    myShape:addEventListener(Event.MOUSE_UP, myShape.onMouseUp, myShape)
    
    return myShape
end
  
-----------------------------------------------------------------------------
function ButtonGrid(width, height, rows, cols, padding)
    local priv = {}
    local public = {}

    local grid = {}
    local buttons = {}
    
    local handler = nil
    local font_file = nil
    
    priv.makegrid = function(rows, cols)
        for i = 1, rows do
            grid[i] = {}

            for j = 1, cols do
                grid[i][j] = {}
            end
        end
    end
    
    priv.makegrid(rows, cols)
 
    priv.btnEvtHandler = function(context)
        if not handler then
            print("no handler set for button event")
            return
        end
        handler(context)
    end

    public.setBtnParams = function( params )
        btn_params = params
    end
    
    public.setHandler = function( func )
        if type(func) ~= "function" then
            return
        end
        handler = func
    end
    
    public.addButton = function(text, row, col)
        if row > #grid then
            return false
        end
        local grow = grid[row]
        if col > #grow then
            return false
        end

        local dx = width / cols
        local dy = height / rows
        local x = (col-1) * dx + dx/2
        local y = (row-1) * dy + dy/2

        local btn = RButton(text, x, y, dx-padding*dx, dy-padding*dy, btn_params)
        btn.setHandler(priv.btnEvtHandler, {text=text, row=row, col=col})
        table.insert(buttons, btn)      
    end

    public.render = function(parent)
        if #buttons < 1 then
            return
        end
        local max = buttons[1].getFontSize()
        for i=2,#buttons do
            local btn = buttons[i]
            local fs = btn.getFontSize()
            if max > fs then
                max = fs
            end            
        end
        
        for i=1,#buttons do
            local btn = buttons[i]
            btn.setFontSize(max)
            parent:addChild(btn)
            btn.drawText()
        end
        
    end

    return public   
end

-----------------------------------------------------------------------------
local g_view_manager = nil

function ViewManager()
    if g_view_manager then
        return g_view_manager
    end
    
    local private = {}
    local public = {}       -- interface seen by creators of ViewManager
    local friend_view = {}  -- methods of ViewManager only seen within View 
    local views = {}
    
    friend_view.leave = function(from, whereTo, params)
        vfrom = views[from]
        vto   = views[whereTo]
        
        local onLeave = vfrom.view.onLeave
        if type(onLeave) == "function" then
            onLeave()
        end
        
        stage:removeChild(vfrom.vstage)
        stage:addChild(vto.vstage)
        
        local onStart = vto.view.onStart
        if type(onStart) == "function" then
            onStart(vto.vstage, params)
        end
    end
    
    private.View = function(name)
        local i_view = {}
        
        i_view.leave = function(whereTo, params)
            friend_view.leave(name, whereTo, params)
        end
        
        return i_view
    end

    public.addView = function(viewname)
        local view = private.View(viewname, friend_view)
        views[viewname] = {view = view, vstage = Sprite.new()}
        return view
    end
    
    public.start = function(viewname)
        local viewinfo = views[viewname]
        if viewinfo == nil then
            return
        end
        stage:addChild(viewinfo.vstage)
        viewinfo.view.onStart(viewinfo.vstage, nil)
    end

    g_view_manager = public        
    return public
end

-----------------------------------------------------------------------------
