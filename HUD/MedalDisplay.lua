-- Register the behaviour
behaviour("MedalDisplay")

function MedalDisplay:Start()
	self.timeToDisplay = 0.25
	self.timer = 0

	self.timePerCharacter = 0.001
	self.charTimer = 0

	--self.textToDisplay = "Headshot! (+100 Points)"
	self.displayText = ""
	self.currentCharacterIndex = 1

	self.lifeTime = 1
	self.init = false
	self.targets.medal.color = Color(1,1,1,0)
end

function MedalDisplay:Update()
	if self.init then

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
	
		if self.textToDisplay == self.displayText then
			self.lifeTime = self.lifeTime - Time.deltaTime
			if self.lifeTime <= 0 then
				GameObject.Destroy(self.script.gameObject)
			end
		end
	end
	self.targets.text.text = self.displayText

	if Input.GetKeyDown(KeyCode.O) then
		self:Init("Headshot! (+100 Points)")
	end
end

function MedalDisplay:Init(textToDisplay)
	self.targets.bg.fillAmount = 0
	self.targets.text.text = ""
	self.displayText = ""
	self.timer = 0
	self.currentCharacterIndex = 1
	self.charTimer = 0
	self.textToDisplay = textToDisplay
	self.targets.medal.color = Color.white
	self.init = true
	print("Init!")
end