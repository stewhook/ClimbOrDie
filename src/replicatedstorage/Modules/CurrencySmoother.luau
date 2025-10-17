local RunService = game:GetService("RunService")

local Module = {}

-- Controller per stat
export type Controller = {
	current: number,
	target: number,
	vel: number,
	response: number,
	zeta: number,
	snapAbs: number,
	snapRel: number,
	epsilon: number,
	cb: ((number) -> ())?,

	-- internal flag to skip work if already at target
	_active: boolean,
}

local controllers: {[string]: Controller} = {}
local conn: RBXScriptConnection? = nil

-- Default tuning (good general-purpose feel)
local DEFAULT_RESPONSE = 0.35
local DEFAULT_ZETA = 1.0
local DEFAULT_SNAP_ABS = math.huge -- off by default; set your own if wanted
local DEFAULT_SNAP_REL = math.huge -- off by default; set your own if wanted
local DEFAULT_EPSILON  = 0.01

-- Internal: start the single shared render loop if needed
local function ensureConnection()
	if conn ~= nil then return end
	conn = RunService.RenderStepped:Connect(function(dt: number)
		local anyActive = false

		for _, c in pairs(controllers) do
			-- Skip if no change expected
			if not c._active then
				continue
			end

			local x = c.current
			local g = c.target
			local v = c.vel
			local delta = g - x

			-- Snap conditions for large jumps:
			--  - absolute: |delta| >= snapAbs
			--  - relative: |delta| >= snapRel * max(1, |x|)
			if math.abs(delta) >= c.snapAbs
				or math.abs(delta) >= (c.snapRel * math.max(1, math.abs(x))) then
				x = g
				v = 0
			else
				-- Critically-damped (configurable zeta) spring toward target
				-- Stable, frame-rate independent Euler integration
				local omega = 4.0 / c.response -- ~98% settle at response seconds
				local a = (g - x) * (omega * omega) - (2 * c.zeta * omega * v)
				v = v + a * dt
				x = x + v * dt

				-- Snap to finish if close enough
				if math.abs(g - x) < c.epsilon and math.abs(v) < c.epsilon then
					x = g
					v = 0
				end
			end

			-- Write back
			c.current = x
			c.vel = v

			-- Emit callback only if bound
			if c.cb then
				c.cb(x)
			end

			-- Determine if we still need stepping
			c._active = not (c.current == c.target and c.vel == 0)
			if c._active then
				anyActive = true
			end
		end

		-- If nobody needs updates, pause the loop
		if not anyActive then
			if conn then conn:Disconnect() end
			conn = nil
		end
	end)
end

-- Create or reset a smoother for a given id
function Module.attach(
	id: string,
	initialValue: number?,
	opts: {
		responseTime: number?,
		zeta: number?,
		snapAbs: number?,
		snapRel: number?,
		epsilon: number?,
	}?
)
	assert(type(id) == "string", "attach(id, ...) requires string id")
	local o = opts or {}
	local c: Controller = {
		current  = initialValue or 0,
		target   = initialValue or 0,
		vel      = 0,
		response = o.responseTime or DEFAULT_RESPONSE,
		zeta     = o.zeta or DEFAULT_ZETA,
		snapAbs  = o.snapAbs or DEFAULT_SNAP_ABS,
		snapRel  = o.snapRel or DEFAULT_SNAP_REL,
		epsilon  = o.epsilon or DEFAULT_EPSILON,
		cb       = nil,
		_active  = false,
	}
	controllers[id] = c
	return id
end

-- Bind a render callback that receives the smoothed value each frame.
function Module.bind(id: string, cb: (number) -> ())
	local c = controllers[id]
	assert(c, ("bind: unknown id '%s'"):format(id))
	c.cb = cb
	-- Emit current immediately so UI is in sync on bind
	cb(c.current)
end

-- Absolute retarget (no tween creation; just changes where we steer)
function Module.setTarget(id: string, value: number)
	local c = controllers[id]
	assert(c, ("setTarget: unknown id '%s'"):format(id))
	if c.target ~= value then
		c.target = value
		c._active = true
		ensureConnection()
	end
end

-- Additive bump; coalesces bursts automatically
function Module.add(id: string, delta: number)
	print("Add Running")
	local c = controllers[id]
	assert(c, ("add: unknown id '%s'"):format(id))
	if delta ~= 0 then
		c.target += delta
		c._active = true
		ensureConnection()
	end
end

-- Optional: get current displayed value (not the authoritative balance)
function Module.get(id: string): number
	local c = controllers[id]
	assert(c, ("get: unknown id '%s'"):format(id))
	return c.current
end

-- Optional: tune parameters after attach (e.g., dynamic UX rules)
function Module.tune(id: string, opts: {responseTime: number?, zeta: number?, snapAbs: number?, snapRel: number?, epsilon: number?})
	local c = controllers[id]
	assert(c, ("tune: unknown id '%s'"):format(id))
	if opts.responseTime then c.response = math.max(1/120, opts.responseTime) end -- clamp to avoid dt explosions
	if opts.zeta then c.zeta = math.max(0.1, opts.zeta) end
	if opts.snapAbs then c.snapAbs = math.max(0, opts.snapAbs) end
	if opts.snapRel then c.snapRel = math.max(0, opts.snapRel) end
	if opts.epsilon then c.epsilon = math.max(1e-6, opts.epsilon) end
end

-- Stop smoothing & release callback (keeps the shared loop for other ids)
function Module.destroy(id: string)
	controllers[id] = nil
	-- If that was the last controller, the loop will auto-stop on the next frame
end

return Module