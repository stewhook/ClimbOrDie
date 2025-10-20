local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GamepassKeys = require(ReplicatedStorage.StaticData.GamepassKeys)
return {
	OldHelmet = {
		Price = 100,
		Title = "Old Helmet",
		Detail = "Protects from getting knocked out once a round.",
	},
	XRay = {
		Price = 200,
		Title = "X-Ray Vision",
		Detail = "See the objects before they can see you.",
	},
	GravityCoil = {
		Price = 400,
		Title = "Gravity Coil",
		Detail = "Jump higher and float back down!",
	},
	PiggyBank = {
		Price = 1000,
		Title = "Piggy Bank",
		Detail = "You're much heavier. But earn more cash.",
	},
	GoldenShield = {
		Price = nil,
        GamepassID = GamepassKeys.GoldenShield,
		Title = "Golden Shield",
		Detail = "Can't get knocked out anymore.",
	},
}