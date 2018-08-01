--[[
This code is MIT licensed, see https://opensource.org/licenses/MIT
Copyright 2018 Amnon David
]]

function dumpTable(table, depth)
    depth = depth or 1
    if not table then
        return 'nil'
    end 
    for k,v in pairs(table) do
        if (type(v) == "table") then
            print(string.rep("  ", depth)..k..":")
            dumpTable(v, depth+1)
        else
            print(string.rep("  ", depth)..k..": ",v)
        end
    end
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
        f = params.roundness or f
        linew = params.line_width or linew 
        fillc = params.fill_color or fillc 
        linec = params.line_color or linec 
        textc = params.text_color or textc 
        focus_fillc = params.focus_fill_color or focus_fillc
        focus_linec = params.focus_line_color or focus_linec
        focus_textc = params.focus_text_color or focus_textc
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

    public.addText = function(row, col, text, params)
        params = params or {}
        params.btn_params = params.btn_params or {}
        bparams = params.btn_params
        bparams.fill_color = bparams.fill_color or 'ffffff'
        bparams.line_color = bparams.line_color or 'ffffff'
        bparams.text_color = bparams.text_color or '000000'
        bparams.focus_fill_color = bparams.fill_color
        bparams.focus_line_color = bparams.line_color
        bparams.focus_text_color = bparams.text_color
        bparams.font_file = 'Vera.ttf'
        public.addButton(row, col, text, nil, params)
    end

    -- Add a button to the grid
    -- row: Which row in the grid the button should be placed in
    -- col: Which column in the grid the button should be placed in
    -- text: Text of the button
    -- btnCallback: function to be called when thi specific button is clicked
    -- params (optional): A table of parameters
    --     btn_params: A table of button parameters. Same structure as that passed to RButton
    --     disp_params: Position parameters
    --         xspan: how many cells should button cover on x axis (default is 1)
    --         yspan: how many cells should button cover on y axis (default is 1)
    --         optfont_group: a string identifying the group of fonts this texts size should sync with 
    public.addButton = function(row, col, text, btnCallback, params)
        local xspan = 1
        local yspan = 1
        local optfont_group = '___'

        local bparams = btn_params
        if params then
            bparams = params.btn_params or btn_params
            if params.disp_params then
                local dp = params.disp_params
                xspan = dp.xspan or xspan
                yspan = dp.yspan or yspan
                optfont_group =  dp.optfont_group or optfont_group
            end
        end

        btnCallback = btnCallback or priv.btnEvtHandler
        if row > #grid then
            return false
        end
        local grow = grid[row]
        if col > #grow then
            return false
        end

        local xleft = cols - col + 1
        local yleft = rows - row + 1
        if xspan < 1 then xspan = 1 end
        if yspan < 1 then yspan = 1 end
        if xspan > xleft then xspan = xleft end
        if yspan > yleft then yspan = yleft end

        local cellx = width / cols
        local celly = height / rows
        local btn_w = xspan * cellx
        local btn_h = yspan * celly
        local x = (col-1) * cellx + btn_w/2
        local y = (row-1) * celly + btn_h/2

        local btn = RButton(text, x, y, btn_w-padding*cellx, btn_h-padding*celly, bparams)
        btn.optfont_group = optfont_group
        btn.setHandler(btnCallback, {text=text, row=row, col=col})
        table.insert(buttons, btn)
    end

    public.render = function(parent)
        priv.parent = parent
        if #buttons < 1 then
            return
        end

        -- Calculate highest common denominator font for each group
        local optfont_group = buttons[1].optfont_group
        local max_for_group = {}

        max_for_group[optfont_group] = buttons[1].getFontSize()
        for i=2,#buttons do
            local btn = buttons[i]
            local fs = btn.getFontSize()
            optfont_group = btn.optfont_group
            if not max_for_group[optfont_group] then
                max_for_group[optfont_group] = fs
            elseif max_for_group[optfont_group] > fs then
                max_for_group[optfont_group] = fs
            end
        end

        -- Set foot size of easch button according to its group's font size
        for i=1,#buttons do
            local btn = buttons[i]
            btn.setFontSize(max_for_group[btn.optfont_group])
            parent:addChild(btn)
            btn.drawText()
        end
    end

    public.clear = function()
        for i=1,#buttons do
            priv.parent:removeChild(buttons[i])
            buttons[i] = nil
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
    local public = {}   -- interface seen by creators of ViewManager
    local views = {}

    private.leave = function(from, whereTo, params)
        vfrom = views[from]
        vfrom.view.onLeave(vfrom.vstage)
        stage:removeChild(vfrom.vstage)

        vto = views[whereTo]
        stage:addChild(vto.vstage)
        vto.view.onStart(vto.vstage, params)
    end

    private.View = function(name)
        local i_view = {} -- interface seen by users of View

        i_view.onStart = function()
            print( "Error: view "..name.." did not define onStart function")
        end

        i_view.onLeave = function()
            print( "view "..name.." did not define onLeave function")
        end

        i_view.leave = function(whereTo, params)
            private.leave(name, whereTo, params)
        end

        return i_view
    end

    public.addView = function(viewname)
        local view = private.View(viewname, private)
        views[viewname] = {view = view, vstage = Sprite.new()}
        return view
    end

    public.start = function(viewname)
        local viewinfo = views[viewname]
        if viewinfo == nil then
            print("Error: No view associated with "..viewname)
            return
        end
        stage:addChild(viewinfo.vstage)
        viewinfo.view.onStart(viewinfo.vstage, nil)
    end

    print("creating new g_view_manager")
    g_view_manager = public
    return public
end

-----------------------------------------------------------------------------
