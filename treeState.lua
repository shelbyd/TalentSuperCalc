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

function TreeState:GetState(nodeId)
    return 'floating';
end

local Builder = {};

function TreeState:Builder()
    return Builder:New();
end

function Builder:New()
    local result = {};
    setmetatable(result, self);
    self.__index = self;
    return result;
end

function Builder:AddOutgoing(from, to)
end

function Builder:CurrentRanks(nodeId, ranks)
end

function Builder:MaxRanks(nodeId, ranks)
end

function Builder:Build()
    return TreeState:New({});
end

if WoWUnit then
    local Tests = WoWUnit('TalentSuperCalc');

    function Tests:PassingTest()
        WoWUnit.AreEqual(1 + 1, 2)
        WoWUnit.Exists(true)
    end
    
    function Tests:FailingTest()
        WoWUnit.AreEqual('Apple', 'Pie')
        WoWUnit.Exists(false)
    end
end