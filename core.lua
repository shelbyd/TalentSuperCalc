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

    self.buttonTextures = self.buttonTextures or {};
    EventUtil.ContinueOnAddOnLoaded('Blizzard_ClassTalentUI', function()
        self:SetupHook();
    end);
end

function Main:IsTalentTreeViewerEnabled()
    return GetAddOnEnableState(UnitName('player'), 'TalentTreeViewer') == 2;
end

function Main:SetupHook()
    ClassTalentFrame.TalentsTab:RegisterCallback(TalentFrameBaseMixin.Event.TalentButtonAcquired, self.OnTalentButtonAcquired, self);
    for talentButton in ClassTalentFrame.TalentsTab:EnumerateAllTalentButtons() do
        self:OnTalentButtonAcquired(talentButton);
    end
end

local YELLOW = {
    r = 1,
    g = 1,
    b = 0,
    a = 0.5,
}

function Main:UpdateColors()
    if(self.buttonTextures) then
        for _, texture in pairs(self.buttonTextures) do
            texture:SetVertexColor(YELLOW.r, YELLOW.g, YELLOW.b, YELLOW.a);
        end
    end
end

local function UpdateNonStateVisualsHook(button)
    Main.buttonTextures[button]:SetShown(true);
end

function Main:OnTalentButtonAcquired(button)
    print(button)
    if not self.buttonTextures[button] then
        self.buttonTextures[button] = button:CreateTexture(nil, 'OVERLAY')
        local texture = self.buttonTextures[button];
        texture:SetAllPoints(button);
        texture:SetTexture('Interface/Tooltips/UI-Tooltip-Background');
        texture:SetVertexColor(YELLOW.r, YELLOW.g, YELLOW.b, YELLOW.a);
        texture:AddMaskTexture(button.IconMask);
        texture:Hide();
        hooksecurefunc(button, 'UpdateNonStateVisuals', UpdateNonStateVisualsHook);
    end
    UpdateNonStateVisualsHook(button);
end

