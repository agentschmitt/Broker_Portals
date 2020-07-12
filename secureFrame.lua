local addonName, addonTable = ...

-- Secure frame handling:
-- Rather than using secure buttons in the menu (has problems), we have one
-- master secureframe that we pop onto menu items on mouseover. This requires
-- some dark magic with OnLeave etc, but it's not too bad.

local secureFrame = CreateFrame("Button", nil, nil, "SecureActionButtonTemplate")
secureFrame:Hide()

local function secureFrame_Show(self, secure)
  local owner = self.owner

  if self.secure then	-- Leftovers from previos owner, clean up! ("Shouldn't" happen but does..)
	  for k,v in pairs(self.secure) do
	    self:SetAttribute(k, nil)
	  end
  end
  self.secure = secure;	-- Grab hold of new secure data

  local scale = owner:GetEffectiveScale()

  self:SetPoint("TOPLEFT", nil, "BOTTOMLEFT", owner:GetLeft() * scale, owner:GetTop() * scale)
  self:SetPoint("BOTTOMRIGHT", nil, "BOTTOMLEFT", owner:GetRight() * scale, owner:GetBottom() * scale)
  self:EnableMouse(true)
  for k,v in pairs(self.secure) do
    self:SetAttribute(k, v)
  end

	secureFrame:SetFrameStrata(owner:GetFrameStrata())
	secureFrame:SetFrameLevel(owner:GetFrameLevel()+1)

  self:Show()
end

local function secureFrame_Hide(self)
  self:Hide()
  if self.secure then
	  for k,v in pairs(self.secure) do
	    self:SetAttribute(k, nil)
	  end
	end
  self.secure = nil
end

secureFrame:SetScript("OnLeave",
	function(self)
		local owner=self.owner
		self:Deactivate()
		owner:GetScript("OnLeave")
	end
)

secureFrame:HookScript("OnMouseUp",
	function(self,...)
		if not self.owner then return end
		local script = self.owner:GetScript("OnMouseUp")
		if not script then return end
		script(self.owner,...)
	end
)

secureFrame:HookScript("OnMouseDown",
	function(self,...)
		if not self.owner then return end
		local script = self.owner:GetScript("OnMouseDown")
		if not script then return end
		script(self.owner,...)
	end
)

function secureFrame:IsOwnedBy(frame)
	return self.owner == frame
end

function secureFrame:Activate(owner, secure)
	if self.owner then		-- "Shouldn't" happen but apparently it does and I cba to troubleshoot...
		if not InCombatLockdown( ) then
			secureFrame_Hide(self)
		end
    end
	self.owner = owner
	if not InCombatLockdown( ) then
		secureFrame_Show(self, secure)
	end
end

function secureFrame:Deactivate()
	if not InCombatLockdown( ) then
		secureFrame_Hide(self)
	end
	self.owner = nil
end

-- END secure frame utilities

addonTable.secureFrame = secureFrame