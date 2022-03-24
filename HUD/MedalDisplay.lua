-- Register the behaviour
behaviour("MedalDisplay")

function MedalDisplay:Awake()
	self.timeToDisplay = 0.25
	self.timer = 0

	self.timeToClean = 0.25
	self.cleanTimer = 0

	self.timePerCharacter = 0.001
	self.charTimer = 0

	self.displayText = ""
	self.currentCharacterIndex = 1

	self.lifeTime = 1.5
	self.init = false
	self.targets.medal.color = Color(1,1,1,0)
	
	self.cleaning = false
	self.canDisplay = true

	self.enabled = true
end

function MedalDisplay:Update()

	if self.enabled then
		if self.init then
			if self.cleaning == false then
				if self.timer < self.timeToDisplay then
					self.timer = self.timer + Time.deltaTime
					self.targets.bg.fillAmount = self.timer/self.timeToDisplay
				elseif self.timer >= self.timeToDisplay then
					if self.charTimer < self.timePerCharacter then
						self.charTimer = self.charTimer + Time.deltaTime
						if self.charTimer >= self.timePerCharacter then
							self.charTimer = 0
							local c = self.textToDisplay:sub(self.currentCharacterIndex, self.currentCharacterIndex)
							self.currentCharacterIndex = self.currentCharacterIndex + 1
							self.displayText = self.displayText .. c
						end
					end
				end
			else
				if self.cleanTimer < self.timeToClean then
					self.cleanTimer = self.cleanTimer + Time.deltaTime
					self.targets.bg.fillAmount = 1 - self.cleanTimer/self.timeToClean
					if self.cleanTimer >= self.timeToClean then
						self.canDisplay = true
						self.init = false
						self.lifeTime = 1.5
					end
				end
			end
			if self.textToDisplay == self.displayText then
				self.lifeTime = self.lifeTime - Time.deltaTime
				if self.lifeTime <= 0 then
					self:Clean()
				end
			end
		end
	
		if self.canDisplay and #self.targets.system.self.medalQueue > 0 then

			local medal = self.targets.system.self.medalQueue[1]
			local medalName = ""
			if(medal.medalType == "KillStreak") then
				medalName = medal.medalName
			end
		
			local bonusText = ""
			if medal.bonusPoints > 0 and medal.multiplierBonus == 0 then
				bonusText = "(+" .. medal.bonusPoints .. " points)"
			elseif medal.bonusPoints == 0 and medal.multiplierBonus > 0 then
				bonusText = "(Multiplier +" .. medal.multiplierBonus .. ")"
			end
		
			self:Init(medalName .. " " .. bonusText)
	
			self.targets.system.self:RemoveTopMedal()
		end
	end

	self.targets.text.text = self.displayText
end

function MedalDisplay:Init(textToDisplay)
	self.targets.bg.fillAmount = 0
	self.targets.text.text = ""
	self.displayText = ""
	self.timer = 0
	self.cleanTimer = 0
	self.currentCharacterIndex = 1
	self.charTimer = 0
	self.textToDisplay = textToDisplay
	self.targets.medal.color = Color.white
	self.init = true
	self.targets.bg.fillOrigin = 0
	self.cleaning = false
	self.canDisplay = false
end

function MedalDisplay:Clean()
	self.targets.medal.color = Color(1,1,1,0)
	self.targets.text.text = ""
	self.displayText = ""
	self.targets.bg.fillOrigin = 1
	self.cleaning = true
end

function MedalDisplay:Disable()
	self.enabled = false
end