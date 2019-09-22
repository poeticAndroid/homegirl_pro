fs.mount("world", "http://homegirl.zone/")
sys.exec("/cmd/workshop.lua")
sys.exec("/cmd/shell.lua", {}, "user:")
sys.exec("user:startup.lua", {}, "user:")
