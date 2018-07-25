require "gidcomps"

local appwidth = application:getDeviceWidth()
local appheight = application:getDeviceHeight()

-- Create a button grid with:
--     Width and height of the screen
--     3 rows, 1 column
--     cell padding of 10%
local grid = ButtonGrid(appwidth, appheight, 3, 1, 0.10)

-- Callback function when one of the buttons in the grid is selected
function onSelected(choice)
	print( choice.row, choice.col, choice.text)
end

-- Add the following buttons. The optimal unified font size for all 
-- the buttons is calculated when the button grid is rendered
grid.addButton("Hello", 1, 1)
grid.addButton("World", 2, 1)
grid.addButton("How are you?", 3, 1)

-- Set the button grid callback handler
grid.setHandler( onSelected )

-- Render the button grid on the stage
grid.render(stage)
