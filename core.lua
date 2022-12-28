local name, TSC = ...;

--@debug@
_G.TalentSuperCalc = TSC;
if not _G.TSC then _G.TSC = TSC; end
--@end-debug@

--- @class TalentSuperCalc_Main
local Main = LibStub('AceAddon-3.0'):NewAddon(name, 'AceConsole-3.0', 'AceHook-3.0', 'AceEvent-3.0');
if not Main then return; end
TSC.Main = Main;

function Main:OnInitialize()
    TalentSuperCalcDB = TalentSuperCalcDB or {};
    self.db = TalentSuperCalcDB;
    self.version = GetAddOnMetadata(name, "Version") or "";

    self:RegisterChatCommand('TSC', function() self:OpenConfig(); end);

    self.buttonOverlays = self.buttonOverlays or {};
    EventUtil.ContinueOnAddOnLoaded('Blizzard_ClassTalentUI', function()
        self:SetupHook();
    end);

    Main:RegisterEvent("TRAIT_TREE_CHANGED", self.OnTraitTreeChanged)
    Main:RegisterEvent("TRAIT_NODE_CHANGED", self.OnTraitNodeChanged)
end

function Main:IsTalentTreeViewerEnabled()
    return GetAddOnEnableState(UnitName('player'), 'TalentTreeViewer') == 2;
end

function Main:SetupHook()
    ClassTalentFrame.TalentsTab:RegisterCallback(TalentFrameBaseMixin.Event.TalentButtonAcquired, self.OnTalentButtonAcquired, self);
    for talentButton in ClassTalentFrame.TalentsTab:EnumerateAllTalentButtons() do
        self:OnTalentButtonAcquired(talentButton);
    end

    -- local configs = C_Traits.GetConfigsByType(1);
    -- for i, config in ipairs(configs) do
    --     DevTools_Dump(C_Traits.GetConfigInfo(config));
    -- end
end

local TRANSPARENT = { r = 0, g = 0, b = 0, a = 0 }
local YELLOW = { r = 1, g = 1, b = 0, a = 0.5 }
local GREEN = { r = 0, g = 1, b = 0, a = 0.5 }
local RED = { r = 1, g = 0, b = 0, a = 0.5 }

function Main:UpdateColors()
    if(self.buttonOverlays) then
        for _, texture in pairs(self.buttonOverlays) do
            texture:SetVertexColor(YELLOW.r, YELLOW.g, YELLOW.b, YELLOW.a);
        end
    end
end

local function UpdateNonStateVisualsHook(button)
    local nodeState = Main:NodeState(button.nodeID);

    local color = TRANSPARENT;
    local shown = true;
    if nodeState == 'floating' then
        color = YELLOW;
    elseif nodeState == 'explicitly_selected' then
        color = GREEN;
    elseif nodeState == 'explicitly_rejected' then
        color = RED;
    elseif nodeState == 'inferred' then
        shown = false;
    else
        error("Unrecognized node state " .. nodeState)
    end

    Main.buttonOverlays[button]:SetVertexColor(color.r, color.g, color.b, color.a);
    Main.buttonOverlays[button]:SetShown(shown);
end

function Main:OnTalentButtonAcquired(button)
    local nodeId = button.nodeID;

    if not self.buttonOverlays[button] then
        self.buttonOverlays[button] = button:CreateTexture(nil, 'OVERLAY')
        local texture = self.buttonOverlays[button];
        texture:SetAllPoints(button);
        texture:SetTexture('Interface/Tooltips/UI-Tooltip-Background');
        texture:AddMaskTexture(button.IconMask);
        texture:Hide();
        hooksecurefunc(button, 'UpdateNonStateVisuals', UpdateNonStateVisualsHook);
    end

    UpdateNonStateVisualsHook(button);
end

-- State things

function Main:NodeState(nodeId)
    -- https://wowpedia.fandom.com/wiki/API_C_Traits.GetNodeInfo
    local nodeInfo = C_Traits.GetNodeInfo(C_ClassTalents.GetActiveConfigID(), nodeId);

    local ranks = nodeInfo.activeRank;
    if ranks == 0 then
        return 'explicitly_rejected';
    end

    for _, edge in ipairs(nodeInfo.visibleEdges) do
        local otherNodeState = self:NodeState(edge.targetNode);
        if otherNodeState == 'inferred' or otherNodeState == 'explicitly_selected' then
            return 'inferred'
        end
    end

    return 'explicitly_selected';
end

function Main:OnTraitTreeChanged(treeId)
    DevTools_Dump(treeId)
end

function Main:OnTraitNodeChanged(nodeId)
    print("OnTraitNodeChanged " .. nodeId)
    local nodeInfo = C_Traits.GetNodeInfo(C_ClassTalents.GetActiveConfigID(), nodeId);
    DevTools_Dump({
        isAvailable = nodeInfo.isAvailable,
    })
end
