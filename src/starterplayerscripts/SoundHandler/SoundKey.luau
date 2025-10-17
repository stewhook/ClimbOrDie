local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local soundFolder = ReplicatedStorage.Sounds
local areaSounds = soundFolder.AreaSounds
local UISounds = SoundService.UI
local localGameSounds = SoundService.InGame


return {
	STONECRASH = areaSounds.FallParts.StoneImpact,
	CONEIMPACT = areaSounds.FallParts.ConeImpact,
	BBALLIMPACT = areaSounds.FallParts.BasketballImpact,
	BEACHIMPACT = areaSounds.FallParts.BeachballImpact,
	SOCCERIMPACT = areaSounds.FallParts.SoccerImpact,
	METALPANG = areaSounds.FallParts.MetalPang,
	KNOCKOUT = areaSounds.Character.KnockedOut,
	PLAYERROUNDREWARD = areaSounds.InGame.PlayerReward,
	ITEMFALLALERT = UISounds.Alerts.PartFallWarning,
	WARNINGSEQUENCE = localGameSounds.SequenceSounds.WarningSequence,
	CARDBOARDIMPACT = areaSounds.FallParts.CardboardImpact,
	CERAMICIMPACT = areaSounds.FallParts.CeramicImpact,
	ITEMEMERGENCYALERT = UISounds.Alerts.EmergencyItem,
	INTERMISSIONSOUND = UISounds.Alerts.IntermissionCountdown,
	LOBBYMUSIC = SoundService.Lobby.LobbyMusic.LobbyMusic,
}
