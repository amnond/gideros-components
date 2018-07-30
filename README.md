# gideros-components
Various components to assist in developing Gideros apps

Gideros (http://giderosmobile.com/) is an amazing project. Hopefully this will contribute a bit more to it.

This project is aimed to create components that make creating Gideros application development even easier

For getting quickly oriented, the easiest method is to download the contained project, run it in Gideros studio and then take a look at main.lua. The simplicity of the code in main.lua makes it rather self explanatory.

# Currently supported components:
* [Rounded Buttons](#rounded_buttons)
* [Button Grid](#button_grid)
* [View Manager](#view_manager)

## <a name="rounded_buttons"></a> Rounded buttons
Rbutton is a configurable rounded-corners button that does not require a bitmap. The optimal font size for the button is automatically set according to the given button dimensions. 

usage:
```
btn = RButton(text, cx, cy, w, h, params)
stage:addChild(btn)
```
where:
* text - a string containing the text of the button
* cx - the horizontal center of the button
* cy - the vertical center of the button
* w - width of the button
* h - height of the button
* params is an optional table that can contain the following attributes:
  + roundness - a number between 0 and 1 that defines the roundness of the corners. where 0 means no rounded corners (i.e the button will be a simple rectangle) and 1 means that the vertical edges of the button will be half a circle (with a radius of half the button height)
  + line_width - the width of the button's border
  + line_color - the color of the button's border
  + fill_color - the background color of the button
  + text_color - the color of the button's text
  + focus_line_color - the color of the button's border when button is clicked
  + focus_fill_color - the background color of the button when button is clicked
  + focus_text_color - the color of the button's text when button is clicked


## <a name="button_grid"></a>Button grid
ButtonGrid makes use of RButton.

Example: The folloging code

```lua
require "gidcomps"

local appwidth = application:getDeviceWidth()
local appheight = application:getDeviceHeight()

-- Create a button grid with:
--     current application Width and height
--     3 rows, 1 column
--     cell padding of 10%
local grid = ButtonGrid(appwidth, appheight, 3, 1, 0.10)
grid.setBtnParams({font_file = 'Vera.ttf'})

-- Define callback function when one of the buttons in the grid is selected
local function onSelected(choice)
    print( choice.row, choice.col, choice.text)
end

-- Add the following buttons. The optimal unified font size for all 
-- the buttons is calculated when the button grid is rendered
grid.addButton(1, 1, "Hello")
grid.addButton(2, 1, "World")
grid.addButton(3, 1, "How are you?")

-- Set the button grid generic callback handler
grid.setHandler( onSelected )

-- Render the button grid on the stage
grid.render(stage)
```
will produce:

![screen shot](https://nocurve.com/content/video.gif "Example")


### GridManager methods ###

* ```clear()``` - clears all the existing GridManager objects that were rendered
* ```addButton(row, col, text, btnCallback, params)``` - Add a button to the grid
  + row: Which row in the grid the button should be placed in
  + col: Which column in the grid the button should be placed in
  + text: Text of the button
  + btnCallback: function to be called when thi specific button is clicked
  + params (optional): A table of parameters:
    * btn_params: A table of button parameters. Same structure as that passed to RButton
    * disp_params: Position parameters
    * xspan: how many cells should button cover on x axis (default is 1)
    * yspan: how many cells should button cover on y axis (default is 1)
    * keep_max_font: Do not attempt to sync this sprite's font size with others on the grid
* ```setBtnParams(params)``` - set the display options for all buttons in this grid. params is the same as for RButton
* ```setHandler(func)``` - set a generic button click handler for buttons who have not been associated with their specific callback function when clicked. All callback functions are called with a parameter of a table containing the row, columns and text of the button clicked.
* ```render(parent)``` - Render the grid and its components on the sprite/stage given in parent parameter

## <a name="view_manager"></a>ViewManager

ViewManager provides a simple way to manage the logic of the different screens that make up your application.

If the internal logic of a certain screen is defined in a specific file, then at the begining of that file get an instance of the ViewManager and request from it an instance of a View associated with a name you provide, as follows:

```lua
require "gidcomps"

local view_mngr = ViewManager()
local view1 = view_mngr.addView("view1")
```

### Override view callbacks
At this point, you should override two callback methods of View:

```lua
function view1.onStart(vstage, params)
```
* vstage - the stage on which to add this views children
* params - parameters that have been passed by the previous view before transfering control to this view

```lua
function view1.onLeave()
```
Implement any required clean-ups before this view is removed from the stage

### Transfer control to different view
To transfer control to a different view, invoke the current view's leave method, for example:

```lua
view1.leave("view2", {msg="hello from view1"})
```

### Start the show
To start the process, call the start method with the name of the first view that should be loaded, so for example from main.lua :

```lua
require "gidcomps"

local view_mngr = ViewManager()
view_mngr.start("view1")
```
