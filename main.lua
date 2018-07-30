require "gidcomps"

local view1 = require "view1"
local view2 = require "view2"
local view3 = require "view3"

local view_mngr = ViewManager()

view1.init(view_mngr)
view2.init(view_mngr)
view3.init(view_mngr)

view_mngr.start("view1")
