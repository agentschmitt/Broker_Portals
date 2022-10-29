assert(LibStub, "LibSecureFrame-1.0 requires LibStub")
local lib, oldminor = LibStub:NewLibrary("LibSecureFrame-1.0", 1)
if not lib then return end

---------------------------------------

local secureFrame = CreateFrame("Button", nil, nil, "SecureActionButtonTemplate")
secureFrame:RegisterForClicks("AnyUp", "AnyDown")
secureFrame:Hide()

---------------------------------------

function lib:Activate(...)
	secureFrame:Activate(...)	
end

function lib:Deactivate(...)
	secureFrame:Deactivate(...)
end

---------------------------------------

-- Secure frame handling:
-- Rather than using secure buttons in the menu (has problems), we have one
-- master secureframe that we pop onto menu items on mouseover. This requires
-- some dark magic with OnLeave etc, but it's not too bad.

function secureFrame:ClearSecure()
	if self.secure then
		for k,v in pairs(self.secure) do
			self:SetAttribute(k, nil)
		end
	end
	self.secure = nil
end

function secureFrame:SetSecure(secure)
	self.secure = secure;	-- Grab hold of new secure data
	for k,v in pairs(self.secure) do
		self:SetAttribute(k, v)
	end
end

function secureFrame:Init(secure)
	self:ClearSecure()
	self:SetSecure(secure)

	local owner = self.owner
	local scale = owner:GetEffectiveScale()

	self:SetPoint("TOPLEFT", nil, "BOTTOMLEFT", owner:GetLeft() * scale, owner:GetTop() * scale)
	self:SetPoint("BOTTOMRIGHT", nil, "BOTTOMLEFT", owner:GetRight() * scale, owner:GetBottom() * scale)
	self:EnableMouse(true)
	self:SetFrameStrata(owner:GetFrameStrata())
	self:SetFrameLevel(owner:GetFrameLevel()+1)
end

function secureFrame:Deactivate()
	if not InCombatLockdown() then
		self:Hide()
		self:ClearSecure()
	end
	self.owner = nil
end

function secureFrame:DeactivateByParent(parent)
	if parent == nil then return end
	parent:SetScript("OnHide", function(self)
		secureFrame:Deactivate()
	end)
end

function secureFrame:Activate(secure, owner, parent)
	if self.owner then		-- "Shouldn't" happen but apparently it does and I cba to troubleshoot...
		if not InCombatLockdown() then
			self:ClearSecure()
		end
    end
	self.owner = owner
	if not InCombatLockdown() then
		self:DeactivateByParent(parent)
		self:Init(secure)
		self:Show()
	end
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
