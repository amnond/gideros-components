require "gidcomps"

local view_mngr = ViewManager()
local view3 = view_mngr.addView("view3")

-- Callback function when one of the buttons in the grid is selected
local function onSelected(choice)
    print( table_dumps(choice) )
end

-- Specific callback function for view1 button
local function onView1Clicked(choice)
    view3.leave("view1", {fromView="view3"})
end

-- Specific callback function for view2 button
local function onView2Clicked(choice)
    view3.leave("view2", {fromView="view3"})
end
-------------------------------------------
-- Override callbacks

--[[
function view2.onLeave()
    print("Leaving view2")
end
]]

local dynspan = 1

local grid = nil

function view3.onLeave()
    grid.clear()
end

function view3.onStart(vstage, params)
    dynspan = dynspan % 3
    dynspan = dynspan + 1

    print('view3.onStart '..table_dumps(params))

    local appwidth = application:getDeviceWidth()
    local appheight = application:getDeviceHeight()

    -- Create a button grid with:
    --     Width and height of the screen
    --     3 rows, 1 column
    --     cell padding of 10%
    grid = ButtonGrid(appwidth, appheight, 3, 4, 0.10)

    grid.setBtnParams({font_file = 'Vera.ttf'})

    -- Add the following buttons. The optimal unified font size for all
    -- the buttons is calculated when the button grid is rendered
    local params1 = { disp_params = { xspan = 4, keep_max_font = true } }
    grid.addButton(1, 1, "In view3", nil, params1)

    local params2 = { disp_params = { xspan = dynspan } }
    grid.addButton(3, 1, "To View1", onView1Clicked, params2)
    local params3 = { disp_params = { xspan = 4-dynspan+1 } }
    grid.addButton(3, dynspan+1, "To View2", onView2Clicked, params3)

    -- Set the button grid callback handler
    grid.setHandler( onSelected )

    grid.render(vstage)
end
