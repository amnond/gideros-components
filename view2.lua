local view2 = nil

local M = {}
M.init = function(view_mngr)
    view2 = view_mngr.addView("view2")

-- Callback function when one of the buttons in the grid is selected
    local function onSelected(choice)
        print( table_dumps(choice) )
    end

    -- Specific callback function for view1
    local function onView1Clicked(choice)
        view2.leave("view1", {fromView="view2"})
    end

    -- Specific callback function for view3
    local function onView3Clicked(choice)
        view2.leave("view3", {fromView="view2"})
    end

    -------------------------------------------
    -- Override callbacks

    --[[
    function view2.onLeave()
        print("Leaving view2")
    end
    ]]
    local grid = nil

    function view2.onStart(vstage, params)
        print('view2.onStart '..table_dumps(params))

        local appwidth = application:getDeviceWidth()
        local appheight = application:getDeviceHeight()

        if not grid then
            -- Create a button grid with:
            --     Width and height of the screen
            --     3 rows, 1 column
            --     cell padding of 10%
            grid = ButtonGrid(appwidth, appheight, 3, 1, 0.10)

            grid.setBtnParams({font_file = 'Vera.ttf'})

            -- Add the following buttons. The optimal unified font size for all 
            -- the buttons is calculated when the button grid is rendered
            grid.addButton(1, 1, "In View2")
            grid.addButton(2, 1, "To View3", onView3Clicked)
            grid.addButton(3, 1, "To View1", onView1Clicked)

            -- Set the button grid callback handler
            grid.setHandler( onSelected )
        end
            
        grid.render(vstage)
    end

end
    
return M