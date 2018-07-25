# gideros-components
Various components to assist in Gideros apps

Gideros (http://giderosmobile.com/) is an amazing project. Hopefully this will contribute a bit more to it.

This project is aimed to create components that make creating Gideros application development even easier

For getting quickly oriented, the easiest method is to download the contained project, run it in Gideros studio and then take a look at main.lua. The simplicity of the code in main.lua makes it rather self explanatory.

# Currently supported components:

## Rounded buttons
Rbutton is a configurable rounded-corners button that does not require a bitmap. The optimal font size for the button is automatically set according to the given button dimensions. 

usage:
```
btn = RButton(text, cx, cy, w, h, params)
stage:addChild(btn)
```
where:
text - a string containing the text of the button
cx - the horizontal center of the button
cy - the vertical center of the button
w - width of the button
h - height of the button
params is an optional table that can contain the following attributes:
+ roundness - a number between 0 and 1 that defines the roundness of the corners. where 0 means no rounded corners (i.e the button will be a simple rectangle) and 1 means that the vertical edges of the button will be half a circle (with a radius of half the button height)
+ line_width - the width of the button's border
+ line_color - the color of the button's border
+ fill_color - the background color of the button
+ text_color - the color of the button's text
+ focus_line_color - the color of the button's border when button is clicked
+ focus_fill_color - the background color of the button when button is clicked
+ focus_text_color - the color of the button's text when button is clicked


## Button grid
ButtonGrid makes use of RButton.
To keep things simple, let's just let the code do the talking:

```lua
require "gidcomps"

local appwidth = application:getDeviceWidth()
local appheight = application:getDeviceHeight()

-- Create a button grid with:
--     current application Width and height
--     3 rows, 1 column
--     cell padding of 10%
local grid = ButtonGrid(appwidth, appheight, 3, 1, 0.10)

-- Define callback function when one of the buttons in the grid is selected
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
```

