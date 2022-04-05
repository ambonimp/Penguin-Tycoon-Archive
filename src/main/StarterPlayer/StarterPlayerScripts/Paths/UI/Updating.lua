local UpdatingUI = {}


--- Main Variables ---
local Paths = require(script.Parent.Parent)

local Services = Paths.Services
local Modules = Paths.Modules
local Remotes = Paths.Remotes
local UI = Paths.UI


--- Updating Functions ---
function UpdatingUI:Initiate()
	-- Updating Money
	local PreviousMoney = Paths.Player:GetAttribute("Money")
	local PreviousGems = Paths.Player:GetAttribute("Gems")
	local PreviousIncome = Paths.Player:GetAttribute("Income")
	
	
	
	-- Initiating Stats
	UI.Top.MoneyDisplay.Amount.Text = Modules.Format:FormatComma(PreviousMoney)
	UI.Top.GemDisplay.Amount.Text = Modules.Format:FormatComma(PreviousGems)
	
	
--- Updating Stats ---
	
	-- Updating Money
	Paths.Player:GetAttributeChangedSignal("Money"):Connect(function()
		local NewMoney = Paths.Player:GetAttribute("Money")
		local MoneyChange = NewMoney - PreviousMoney
		PreviousMoney = NewMoney

		--UI.Bottom.MoneyDisplay.Money.Text = "$ "..Modules.Format:FormatComma(NewMoney)

		-- Display Money Change Animation
		Modules.UIAnimations:MoneyChanged(MoneyChange, NewMoney)
	end)
	
	-- Updating Gems
	Paths.Player:GetAttributeChangedSignal("Gems"):Connect(function()
		local NewGems = Paths.Player:GetAttribute("Gems")
		local GemsChange = NewGems - PreviousGems
		PreviousGems = NewGems

		--UI.Bottom.MoneyDisplay.Money.Text = "$ "..Modules.Format:FormatComma(NewMoney)

		-- Display Money Change Animation
		Modules.UIAnimations:GemsChanged(GemsChange, NewGems)
	end)
	
	-- Updating Income
	Paths.Player:GetAttributeChangedSignal("Income"):Connect(function()
		local NewIncome = Paths.Player:GetAttribute("Income")
		local IncomeChange = NewIncome - PreviousIncome
		PreviousIncome = NewIncome

		-- Display Income Change Animation
		Modules.UIAnimations:IncomeChanged(IncomeChange, NewIncome)
		Modules.Money:UpdateMoneyRewards() -- Update the money product values in the store
	end)
	
	
	spawn(function()
		repeat wait() until Paths.Player:GetAttribute("Next5Gems")
		local tim = Paths.Player:GetAttribute("Next5Gems")-os.time()
		Paths.Player:GetAttributeChangedSignal("Next5Gems"):Connect(function()
			tim = Paths.Player:GetAttribute("Next5Gems")
			tim = tim-os.time()
		end)
		while wait(1) do
			tim = tim-1
			if tim > 0 then
				if tim > 120 then
					Paths.UI.Left.GemDisplay.Amount.Text = "Next Reward in "..string.format("%02i:%02i", tim/60%60, tim%60)
				elseif tim > 60 then
					Paths.UI.Left.GemDisplay.Amount.Text = "Next Reward in "..string.format("%02i:%02i", tim/60%60, tim%60)
				else
					Paths.UI.Left.GemDisplay.Amount.Text = "Next Reward in "..string.format("%02i:%02i", tim/60%60, tim%60)
				end
			else
				Paths.UI.Left.GemDisplay.Amount.Text = "Next Reward in 15:00"
			end
		end
	end)
end



return UpdatingUI
