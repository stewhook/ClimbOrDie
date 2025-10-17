local dataKey = {
    OldHelmet = {
        Uses = 1,
    },
    GoldenShield = {
        Uses = math.huge
    },
    PiggyBank = nil,
    XRay = nil,
    Balloon = nil,
}

local startFunctions = {
}

local endFunctions = {
}

local function buildData(player: Player, gearID: string?)
    gearID = gearID or nil
    if not player then return end
    local table = {
        EquippedGear = gearID,
        StartFunction = startFunctions[gearID],
        EndFunction = endFunctions[gearID],
        GearData = dataKey[gearID]
    }
    return table
end

return {
    BuildData = buildData
}