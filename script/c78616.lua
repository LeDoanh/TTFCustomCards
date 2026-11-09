-- Velvetect Sanctuary – Pandemonium Hall
local s,id=GetID()
function s.initial_effect(c)
	-- Activate: Foolish 1 Velvetect or Purrfect
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)

	-- Trigger: Control changed or material detached -> attach 1 card from either GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_CONTROL_CHANGED)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.atcon1)
	e2:SetTarget(s.attg)
	e2:SetOperation(s.attop)
	c:RegisterEffect(e2)
	local e2b=Effect.CreateEffect(c)
	e2b:SetDescription(aux.Stringid(id,0))
	e2b:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2b:SetCode(EVENT_DETACH_MATERIAL)
	e2b:SetProperty(EFFECT_FLAG_DELAY)
	e2b:SetRange(LOCATION_FZONE)
	e2b:SetCountLimit(1,{id,1})
	e2b:SetTarget(s.attg)
	e2b:SetOperation(s.attop)
	c:RegisterEffect(e2b)

	-- Material Effect: Double battle damage
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_XMATERIAL)
	e3:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e3:SetValue(s.damval)
	c:RegisterEffect(e3)

	-- Detach Effect: Add or activate Field Spell
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,{id,2})
	e4:SetCondition(s.fscon)
	e4:SetTarget(s.fstg)
	e4:SetOperation(s.fsop)
	c:RegisterEffect(e4)
end
s.listed_series={0x786,0x777}

function s.tgfilter(c)
	return (c:IsSetCard(0x786) or c:IsSetCard(0x777)) and c:IsAbleToGrave()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.SendtoGrave(g,REASON_EFFECT)
		end
	end
end

function s.atcon1(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(function(c,p) return c:IsType(TYPE_XYZ) and c:GetOwner()==p end,1,nil,tp)
end
function s.attg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(function(c) return c:IsFaceup() and c:IsType(TYPE_XYZ) end,tp,LOCATION_MZONE,0,1,nil)
		and Duel.GetFieldGroupCount(tp,LOCATION_GRAVE,LOCATION_GRAVE)>0 end
end
function s.attop(e,tp,eg,ep,ev,re,r,rp)
	local xyzg=Duel.GetMatchingGroup(function(c) return c:IsFaceup() and c:IsType(TYPE_XYZ) end,tp,LOCATION_MZONE,0,nil)
	if #xyzg==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local g=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil)
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		local tc=xyzg:Select(tp,1,1,nil):GetFirst()
		if tc and not tc:IsImmuneToEffect(e) then
			Duel.Overlay(tc,g)
		end
	end
end

function s.damval(e,val)
	return val*2
end

function s.fscon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_COST) and re:IsActivated() and re:IsActiveType(TYPE_XYZ)
end
function s.fsfilter(c,tp)
	return c:IsSetCard(0x786) and c:IsType(TYPE_FIELD) and (c:IsAbleToHand() or c:GetActivateEffect():IsActivatable(tp,true,true))
end
function s.fstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.fsfilter,tp,LOCATION_DECK,0,1,nil,tp) end
end
function s.fsop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local tc=Duel.SelectMatchingCard(tp,s.fsfilter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
	if tc then
		local b1=tc:IsAbleToHand()
		local b2=tc:GetActivateEffect():IsActivatable(tp,true,true)
		if b1 and (not b2 or Duel.SelectOption(tp,1190,1150)==0) then
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,tc)
		else
			Duel.ActivateFieldSpell(tc,e,tp,eg,ep,ev,re,r,rp)
		end
	end
end
