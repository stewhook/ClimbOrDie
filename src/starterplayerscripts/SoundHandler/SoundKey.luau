local ReplicatedStorage = game:GetService("ReplicatedStorage")
local soundFolder = ReplicatedStorage.Sounds
local areaSounds = soundFolder.AreaSounds

return {
	STONECRASH = areaSounds.FallParts.StoneImpact,
	CONEIMPACT = areaSounds.FallParts.ConeImpact,
	BBALLIMPACT = areaSounds.FallParts.BasketballImpact,
	BEACHIMPACT = areaSounds.FallParts.BeachballImpact,
	SOCCERIMPACT = areaSounds.FallParts.SoccerImpact,
	METALPANG = areaSounds.FallParts.MetalPang,
	KNOCKOUT = areaSounds.Character.KnockedOut,
	PLAYERROUNDREWARD = areaSounds.InGame.PlayerReward,
}
