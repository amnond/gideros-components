require "gidcomps"

local view_mngr = ViewManager()
local view2 = view_mngr.addView("view2")

function view2.onLeave()
    print("Leaving view2")
end

function view2.onStart(vstage, params)
    print('view2.onStart '..table_dumps(params))
    
    local appwidth = application:getDeviceWidth()
    local appheight = application:getDeviceHeight()
    
    -- Create a button grid with:
    --     Width and height of the screen
    --     3 rows, 1 column
    --     cell padding of 10%
    local grid = ButtonGrid(appwidth, appheight, 3, 1, 0.10)
    view2.grid = grid

    grid.setBtnParams({font_file = 'Vera.ttf'})

    -- Add the following buttons. The optimal unified font size for all 
    -- the buttons is calculated when the button grid is rendered
    grid.addButton("Cosmetic button", 1, 1)
    grid.addButton("To View1", 3, 1)

    -- Set the button grid callback handler
    grid.setHandler( view2.onSelected )
    
    grid.render(vstage)
end

-- Create callback function when one of the buttons in the grid is selected
function view2.onSelected(choice)
    print( table_dumps(choice) )
    if choice.row == 3 then
        view2.leave("view1", {param="that"})
    end
end
