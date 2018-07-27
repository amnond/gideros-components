require "gidcomps"

local view_mngr = ViewManager()
local view1 = view_mngr.addView("view1")

-- Callback function when one of the buttons in the grid is selected
local function onSelected(choice)
    print( table_dumps(choice) )
end

--  Specific callback function for view2
local function onView2Clicked(choice)
    view1.leave("view2", {fromView="view1"})
end

-------------------------------------------
-- Override callbacks

function view1.onLeave()
    print("Leaving view1")
end

function view1.onStart(vstage, params)
    print('view1.onStart '..table_dumps(params))

    local appwidth = application:getDeviceWidth()
    local appheight = application:getDeviceHeight()

    -- Create a button grid with:
    --     Width and height of the screen
    --     3 rows, 1 column
    --     cell padding of 10%
    local grid = ButtonGrid(appwidth, appheight, 3, 1, 0.10)

    grid.setBtnParams({font_file = 'Vera.ttf'})

    -- Add the following buttons. The optimal unified font size for all 
    -- the buttons is calculated when the button grid is rendered
    grid.addButton(1, 1, "In View1")
    grid.addButton(2, 1, "Does nothing")
    grid.addButton(3, 1, "To View2",  onView2Clicked)

    -- Set the button grid callback handler
    grid.setHandler( onSelected )
    
    grid.render(vstage)
end
    
