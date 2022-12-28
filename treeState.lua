local name, TSC = ...;
if TSC.Selections and TSC.Tree then return; end

local Selections = {};
TSC.Selections = Selections;

function Selections:New(initialState)
    local result = initialState or {};
    result.selections = result.selections or {};

    setmetatable(result, self);
    self.__index = self;

    return result;
end

function Selections:GetState(nodeId)
    if self.selections[nodeId] == true then
        return 'selected';
    end

    if self.selections[nodeId] == false then
        return 'rejected';
    end
end

function Selections:InferFromTree(tree)
    -- TODO(shelbyd): Implement.
    return self:New({});
end

local Tree = {};
TSC.Tree = Tree;

function Tree:New()
    local result = {
        graph = {},
        currentRanks = {},
        maxRanks = {},
    };
    setmetatable(result, self);
    self.__index = self;
    return result;
end

function Tree:AddOutgoing(from, to)
    self.graph[from] = self.graph[from] or {};
    self.graph[from][to] = true;
end

function Tree:CurrentRanks(nodeId, ranks)
    self.currentRanks[nodeId] = ranks;
end

function Tree:MaxRanks(nodeId, ranks)
    self.maxRanks[nodeId] = ranks;
end

function Tree:GetState(nodeId)
    return 'inferred';
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