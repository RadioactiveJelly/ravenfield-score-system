-- Register the behaviour
behaviour("MedalSystem")

function MedalSystem:Awake()
	self.gameObject.name = "Medal System"
	self.medalQueue = {}
end

function MedalSystem:Start()
	GameEvents.onActorDied.AddListener(self,"onActorDied")
	GameEvents.onCapturePointCaptured.AddListener(self,"onCapturePointCaptured")
	GameEvents.onActorSpawn.AddListener(self,"onActorSpawn")
	GameEvents.onMatchEnd.AddListener(self,"onMatchEnd")
	GameEvents.onPlayerDealtDamage.AddListener(self,"onPlayerDealtDamage")

	--Kill Medals
	self.killStreak = 0
	self.lastKillStreak = ""

	--[[self.actors = ActorManager.actors
	for i = 1, #self.actors, 1 do
		if not self.actors[i].isPlayer and Player.actor.team ~= self.actors[i].team then
			self.actors[i].onTakeDamage.AddListener(self,"onTakeDamage")
		end
	end]]--

	self.timeForRapidKills = 5
	self.rapidKillsTimer = 0
	self.rapidKills = 0

	local scoreSystemObj = self.gameObject.Find("Score System")
	if scoreSystemObj then
		self.scoreSystem = scoreSystemObj.GetComponent(ScriptedBehaviour)
	end
end

function MedalSystem:Update()
	
	--[[if(Input.GetKeyDown(KeyCode.O)) then
		self:GenerateMedal("Point Captured", "Other", 300, 0)
	end]]--

	if(self.rapidKillsTimer > 0) then
		self.rapidKillsTimer = self.rapidKillsTimer - Time.deltaTime
		if(self.rapidKillsTimer <= 0 or self.rapidKills >= 9) then
			self:EvaluateRapidKills()
			self.rapidKills = 0
		end
	end
end

function MedalSystem:onActorDied(actor, source, isSilent)
	if actor.isPlayer then
		self.killStreak = 0
		self.lastKillStreak = ""
	end

	if source then
		if source.isPlayer and actor.team ~= source.team then
			self.killStreak = self.killStreak + 1
			self:CheckStreak()
			self.rapidKillsTimer = self.timeForRapidKills
			self.rapidKills = self.rapidKills + 1
		end
	end
end

function MedalSystem:CheckStreak()
	local streak = self.killStreak
	if streak >= 31 then
		self:GenerateMedal("Unstoppable", "KillStreak", 100, 0)
	elseif streak == 30 then
		self:GenerateMedal("Nuclear", "KillStreak", 0, 0.2)
	elseif streak == 25 then
		self:GenerateMedal("Brutal", "KillStreak", 0, 0.2)
	elseif streak == 20 then
		self:GenerateMedal("Relentless", "KillStreak", 0, 0.2)
	elseif streak == 15 then
		self:GenerateMedal("Ruthless", "KillStreak", 0, 0.2)
	elseif streak == 10 then
		self:GenerateMedal("Merciless", "KillStreak", 0, 0.2)
	elseif streak == 5 then
		self:GenerateMedal("Bloodthirsty", "KillStreak", 500, 0)
	end
end

function MedalSystem:EvaluateRapidKills()
	local rapidKills = self.rapidKills
	local medalType = "RapidKills"

	local bonusPoints = 0

	if rapidKills >= 9 then
		self:GenerateMedal("KillChain", medalType, 1000, 0)
	elseif rapidKills >= 8 then
		self:GenerateMedal("OctaChain", medalType, 800, 0)
	elseif rapidKills >= 7 then
		self:GenerateMedal("HeptaChain", medalType, 700, 0)
	elseif rapidKills >= 6 then
		self:GenerateMedal("HexaChain", medalType, 600, 0)
	elseif rapidKills >= 5 then
		self:GenerateMedal("PentaChain", medalType, 500, 0)
	elseif rapidKills >= 4 then
		self:GenerateMedal("QuadChain", medalType, 400, 0)
	elseif rapidKills >= 3 then
		self:GenerateMedal("TripleChain", medalType, 300, 0)
	elseif rapidKills >= 2 then
		self:GenerateMedal("DoubleChain", medalType, 200, 0)
	end
end

function MedalSystem:RemoveTopMedal()
	table.remove(self.medalQueue,1)
end

--[[function MedalSystem:onTakeDamage(actor, source, info)
	if actor.isDead then
		return
	end

	if source and source.isPlayer and source.team ~= actor.team then
		if info.healthDamage >= actor.health then
			if info.isCriticalHit and not info.isSplashDamage then
				self:GenerateMedal("Headshot", "Kill", 100, 0)
			end

			if ActorManager.ActorDistanceToPlayer(actor) >= 50 and not info.isSplashDamage then
				self:GenerateMedal("Longshot", "Kill", 50, 0)
			end

			local capPoint = Player.actor.currentCapturePoint
			if capPoint then
				if capPoint.owner == Player.actor.team then
					bonus = bonus + 10
					self:GenerateMedal("Defensive Kill", "Kill", 50, 0)
				else
					self:GenerateMedal("Offensive Kill", "Kill", 50, 0)
				end
			end
		end
	end
end]]--

function MedalSystem:GenerateMedal(medalName, medalType, bonusPoints, multiplierBonus)

	local medalData = {}
	medalData.medalType = medalType
	medalData.medalName = medalName
	medalData.bonusPoints = bonusPoints
	medalData.multiplierBonus = multiplierBonus

	if self.scoreSystem then
		if bonusPoints > 0 then
			self.scoreSystem.self:AddScore(bonusPoints, true, false)
		end
		
		if multiplierBonus > 0 then
			self.scoreSystem.self:AddMultiplier(multiplierBonus)
		end
	end

	table.insert(self.medalQueue, medalData)

end

function MedalSystem:DisableDefaultHUD()
	self.targets.hud.self:Disable()
	self.targets.hud.gameObject.SetActive(false)
end

function MedalSystem:onCapturePointCaptured(capturePoint, newOwner)
	if self.hasSpawnedOnce and not Player.actor.isDead then
		if Player.actor.currentCapturePoint == capturePoint and Player.actor.team == newOwner then
			self:GenerateMedal("Point Captured", "Other", 300, 0)
		end
	end
end

function MedalSystem:onMatchEnd(team)
	if Player.actor.team == team then
		self:GenerateMedal("Victory", "Other", 2500, 0)
	end
end

function MedalSystem:onActorSpawn(actor)
	if(actor == Player.actor) then
		self.hasSpawnedOnce = true
	end
end

function MedalSystem:onPlayerDealtDamage(damageInfo, hitInfo)
	if hitInfo.actor == nil then return end
	if hitInfo.actor.isDead then return end

	if Player.actor.team ~= hitInfo.actor.team then
		if damageInfo.healthDamage >= hitInfo.actor.health then
			if damageInfo.isCriticalHit and not damageInfo.isSplashDamage then
				self:GenerateMedal("Headshot", "Kill", 100, 0)
			end

			if ActorManager.ActorDistanceToPlayer(hitInfo.actor) >= 50 and not damageInfo.isSplashDamage then
				self:GenerateMedal("Longshot", "Kill", 50, 0)
			end

			local capPoint = Player.actor.currentCapturePoint
			if capPoint then
				if capPoint.owner == Player.actor.team then
					self:GenerateMedal("Defensive Kill", "Kill", 25, 0)
				else
					self:GenerateMedal("Offensive Kill", "Kill", 50, 0)
				end
			end
		end
	end
end