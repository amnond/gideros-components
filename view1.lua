require "gidcomps"

local view_mngr = ViewManager()
local view1 = view_mngr.addView("view1")

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
    grid.addButton("Hello", 1, 1)
    grid.addButton("World", 2, 1)
    grid.addButton("How are you?", 3, 1)

    -- Set the button grid callback handler
    grid.setHandler( view1.onSelected )
    
    grid.render(vstage)
end
    
-- Callback function when one of the buttons in the grid is selected
function view1.onSelected(choice)
    print( table_dumps(choice) )
    if choice.text == "World" then
        view1.leave("view2", {hello="hello"})
    end
end
