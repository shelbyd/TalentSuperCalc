local name, TSC = ...;

if TSC.TreeState then return; end
local TreeState = {};
TSC.TreeState = TreeState;

function TreeState:New()
    local result = {};
    setmetatable(result, self);
    self.__index = self;
    return result;
end