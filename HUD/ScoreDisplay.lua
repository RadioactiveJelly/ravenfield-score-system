-- Register the behaviour
behaviour("ScoreDisplay")

function ScoreDisplay:Start()
	--GameEvents.onActorSpawn.AddListener(self,"onActorSpawn")
	--GameEvents.onActorDied.AddListener(self,"onActorDied")

	self.scoreSystem = self.targets.scoreSystem
	self.timeBeforeDecay = 1.5

	self.timer = 0
	self.fadeTimer = 0

	self.displayTotal = 0
	if self.targets.finalScore then
		self.targets.finalScore.text = ""
	end
	

	self.targets.canvasGroup.alpha = 0
	self.alpha = 1
	self.scale = 2
	self.pointsGO = self.targets.scoreText.gameObject

	print(self.scoreSystem.gameObject.name)
	self.enabled = true

	GameEvents.onMatchEnd.AddListener(self,"MatchEnd")
end

function ScoreDisplay:Update()

	if self.enabled == false then
		return
	end

	self.timer = self.timer + Time.deltaTime
	self.fadeTimer = self.fadeTimer + Time.deltaTime

	if self.scoreSystem then
		if #self.scoreSystem.self.pointsHistory > 0 then
			local score = self.scoreSystem.self.pointsHistory[1]
			table.remove(self.scoreSystem.self.pointsHistory,1)
			self.displayTotal = self.displayTotal + score
			self.fadeTimer = 0
			self.targets.scoreText.text = "+" .. self.displayTotal
			if(self.scoreSystem.self.scoreMultiplier > 1) then
				self.targets.multiplierText.text = "Multiplier x" .. self.scoreSystem.self.scoreMultiplier
			else
				self.targets.multiplierText.text = ""
			end
			self.timeBeforeDecay = 1.5
			self.scale = 2
			self.alpha = 1
			self.targets.canvasGroup.alpha = self.alpha
		end

		if self.timeBeforeDecay <= 0 then
			if self.alpha > 0 then
				self.targets.canvasGroup.alpha = self.alpha
				self.alpha = self.alpha - Time.deltaTime * 1
				if self.alpha <= 0 then
					self.alpha = 0
					self.displayTotal = 0
					self.targets.canvasGroup.alpha = 0
				end
			end
		else
			self.timeBeforeDecay = self.timeBeforeDecay - Time.deltaTime
		end

		if self.scale > 1 then
			self.scale = self.scale - (Time.deltaTime * 5)
			if self.scale < 1 then
				self.scale = 1
			end
			self.pointsGO.transform.localScale = Vector3(self.scale, self.scale, 0)
		end
	end
	
end

function ScoreDisplay:Disable()
	self.enabled = false
end


function ScoreDisplay:MatchEnd(team)
	self.targets.finalText.text = "Final Score: " .. self.scoreSystem.self.totalPoints
end