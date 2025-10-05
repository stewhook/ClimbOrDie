itemspawnhandler = require(script.Parent.FallItemService.ItemSpawnHandler)
hitboxdata = require(script.Parent.FallItemService.HitboxData)

cachedHitboxes = hitboxdata.getHitboxes()
cachedTotalWeight = hitboxdata.getTotalWeight()

--itemspawnhandler.StartHitboxSpawnLoop(0.25, 100, cachedHitboxes, cachedTotalWeight)