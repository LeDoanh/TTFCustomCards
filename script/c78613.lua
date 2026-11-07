-- Velvetect Genesis – Continuum
local s,id=GetID()
function s.initial_effect(c)
	-- Cannot be used as material for Xyz Summon
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	e0:SetValue(1)
	c:RegisterEffect(e0)

	-- Xyz procedure: 3+ Level 12 hoặc quái Xyz có 12+ materials
	Xyz.AddProcedure(c,nil,12,3,s.ovfilter,aux.Stringid(id,0),12,s.xyzop)
	c:EnableReviveLimit()

	-- Unaffected by opponent activated effects
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetValue(function(e,te) return te:GetOwnerPlayer()~=e:GetHandlerPlayer() and te:IsActivated() end)
	c:RegisterEffect(e1)

	-- Quick Effect: Detach 3, send all opponent cards to GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(s.cost3)
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2,false,REGISTER_FLAG_DETACH_XMAT)

	-- Trigger: Each time card sent to opponent GY -> attach top card of opponent Deck
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(function(e,tp,eg) return eg:IsExists(function(c,p) return c:IsControler(1-p) end,1,nil,tp) end)
	e3:SetTarget(s.attg)
	e3:SetOperation(s.atop)
	c:RegisterEffect(e3)

	-- While 12+ materials: Opponent cannot activate cards or effects in GY
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCode(EFFECT_CANNOT_ACTIVATE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(0,1)
	e4:SetCondition(function(e) return e:GetHandler():GetOverlayCount()>=12 end)
	e4:SetValue(function(e,re,tp) return re:GetActivateLocation()==LOCATION_GRAVE end)
	c:RegisterEffect(e4)
end
s.listed_series={0x786}

function s.ovfilter(c,tp,lc)
	return c:IsFaceup() and c:IsType(TYPE_XYZ,lc,SUMMON_TYPE_XYZ,tp) and c:GetOverlayCount()>=12
end
function s.xyzop(e,tp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	return true
end

function s.cost3(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,3,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,3,3,REASON_COST)
end

function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_ONFIELD,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,#g,0,0)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_ONFIELD,nil)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end

function s.attg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>0 end
end
function s.atop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and not c:IsImmuneToEffect(e) and Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>0 then
		local tc=Duel.GetDecktopGroup(1-tp,1):GetFirst()
		if tc and tc:IsCanOverlay() then
			Duel.DisableShuffleCheck()
			Duel.Overlay(c,tc)
		end
	end
end
