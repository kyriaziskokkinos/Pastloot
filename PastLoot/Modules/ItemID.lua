﻿local PastLoot = LibStub("AceAddon-3.0"):GetAddon("PastLoot")
local L = LibStub("AceLocale-3.0"):GetLocale("PastLoot")

--[[
Checklist if creating a new module
- first choose an existing module that most closely matches what you want to do
- modify module_key, module_name, module_tooltip to unique values
- make sure to update locales
- Modify SetMatch and GetMatch
- Create/Modify local functions as needed
]]
local module_key = "ItemIDs"
local module_name = L["Item ID"]
local module_tooltip = L["Selected rule will match on item names."]

local module = PastLoot:NewModule(module_name)

module.ConfigOptions_RuleDefaults = {
  -- { VariableName, Default },
  {
    module_key,
    -- {
    -- [1] = { Name, Type, Exception }
    -- },
  },
}
module.NewFilterValue_ID = L["Temp Item ID"]

function module:OnEnable()
  self:RegisterDefaultVariables(self.ConfigOptions_RuleDefaults)
  self:AddWidget(self.Widget)
end

function module:OnDisable()
  self:UnregisterDefaultVariables()
  self:RemoveWidgets()
end

function module:CreateWidget()
  local frame_name = "PastLoot_Frames_Widgets_ItemID"
  return PastLoot:CreateTextBoxOptionalCheckBox(self, module_name, frame_name, module_tooltip)
end

module.Widget = module:CreateWidget()

-- Local function to get the data and make sure it's valid data
function module.Widget:GetData(RuleNum)
  local Data = module:GetConfigOption(module_key, RuleNum)
  local Changed = false
  if (Data) then
    if (type(Data) == "table" and #Data > 0) then
      for Key, Value in ipairs(Data) do
        if (type(Value) ~= "table" or type(Value[1]) ~= "string") then
          Data[Key] = {
            module.NewFilterValue_ID,
            false
          }
          Changed = true
        end
      end
    else
      Data = nil
      Changed = true
    end
  end
  if (Changed) then
    module:SetConfigOption(module_key, Data)
  end
  return Data or {}
end

function module.Widget:GetNumFilters(RuleNum)
  local Value = self:GetData(RuleNum)
  return #Value
end

function module.Widget:AddNewFilter()
  local Value = self:GetData()
  local NewTable = {
    module.NewFilterValue_ID,
    false
  }
  table.insert(Value, NewTable)
  module:SetConfigOption(module_key, Value)
end

function module.Widget:RemoveFilter(Index)
  local Value = self:GetData()
  table.remove(Value, Index)
  if (#Value == 0) then
    Value = nil
  end
  module:SetConfigOption(module_key, Value)
end

function module.Widget:DisplayWidget(Index)
  if (Index) then
    module.FilterIndex = Index
  end
  local Value = self:GetData()
  if (not Value or not Value[module.FilterIndex]) then
    return
  end
  module.Widget.TextBox:SetText(Value[module.FilterIndex][1])
  module.Widget.TextBox:SetScript("OnUpdate", function(...) module:ScrollLeft(...) end)
end

function module.Widget:GetFilterText(Index)
  local Value = self:GetData()
  return Value[Index][1]
end

function module.Widget:IsException(RuleNum, Index)
  local Data = self:GetData(RuleNum)
  return Data[Index][3]
end

function module.Widget:SetException(RuleNum, Index, Value)
  local Data = self:GetData(RuleNum)
  Data[Index][3] = Value
  module:SetConfigOption(module_key, Data)
end

function module.Widget:SetMatch(ItemLink, Tooltip)
  module.CurrentMatch = select(3, ItemLink:find("item:(%d-):"))
  module:Debug("Item ID: " .. (module.CurrentMatch or ""))
end

function module.Widget:GetMatch(RuleNum, Index)
  local RuleValue = self:GetData(RuleNum)
  local ID = RuleValue[Index][1], RuleValue[Index][2]
  if module.CurrentMatch == ID then
    module:Debug("Found item ID match")
    return true
  end

  return false
end

-- should be SetItemID, but trying to template the Widget creation
function module:SetItemName(Frame)
  local Value = self.Widget:GetData()
  Value[self.FilterIndex][1] = Frame:GetText()
  self:SetConfigOption(module_key, Value)
end