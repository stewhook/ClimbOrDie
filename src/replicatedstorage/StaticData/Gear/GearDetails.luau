local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GamepassKeys = require(ReplicatedStorage.StaticData.GamepassKeys)
return {
	OldHelmet = {
		Price = 100,
		Title = "Old Helmet",
		Detail = "Protects from getting knocked out once a round.",
		Image = "rbxassetid://108332327796068",
	},
	XRay = {
		Price = 200,
		Title = "X-Ray Vision",
		Detail = "See the objects before they can see you.",
		Image = "rbxassetid://74006917918246",
	},
	GravityCoil = {
		Price = 400,
		Title = "Gravity Coil",
		Detail = "Jump higher and float back down!",
		Image = "rbxassetid://101358993943273",
	},
	PiggyBank = {
		Price = 1000,
		Title = "Piggy Bank",
		Detail = "You're much heavier. But earn more cash.",
		Image = "rbxassetid://88369823745413",
	},
	GoldenShield = {
		Price = nil,
		GamepassID = GamepassKeys.GoldenShield,
		Title = "Golden Shield",
		Detail = "Can't get knocked out anymore.",
		Image = "rbxassetid://80429381139566",
	},
}
