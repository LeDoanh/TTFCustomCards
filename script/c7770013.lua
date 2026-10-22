-- Purrfect Polarity - Light and Shadow
local s,id=GetID()
local SET_PURRFECT=0x777
function s.initial_effect(c)
	-- Activate: Search 1 monster
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)

	-- Attach 1 Purrfect card when control changes
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_CONTROL_CHANGED)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCondition(s.attcon)
	e2:SetTarget(s.atttg)
	e2:SetOperation(s.attop)
	c:RegisterEffect(e2)

	-- Protection for your Xyz on opponent field
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetTarget(s.indtg)
	e3:SetValue(aux.indoval)
	c:RegisterEffect(e3)

	-- Material grant: Opponent monsters lose 500 ATK/DEF per material
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_XMATERIAL+EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetCondition(s.auracon)
	e4:SetValue(s.atkval)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e5)

	-- Detach trigger: Activate 1 Field Spell from Deck/GY
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,2))
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e6:SetProperty(EFFECT_FLAG_DELAY)
	e6:SetCode(EVENT_TO_GRAVE)
	e6:SetCondition(s.fdcon)
	e6:SetTarget(s.fdtg)
	e6:SetOperation(s.fdop)
	c:RegisterEffect(e6)
end
s.listed_series={SET_PURRFECT}

function s.thfilter(c)
	return c:IsSetCard(SET_PURRFECT) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end

function s.attcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(function(tc) return tc:IsType(TYPE_XYZ) and tc:GetOwner()==tp end,1,nil)
end
function s.matfilter(c)
	return c:IsSetCard(SET_PURRFECT)
end
function s.atttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.matfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil) end
end
function s.attop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:Filter(function(c) return c:IsType(TYPE_XYZ) and c:GetOwner()==tp end,nil):GetFirst()
	if tc and tc:IsFaceup() then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
		local g=Duel.SelectMatchingCard(tp,s.matfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil)
		if #g>0 then
			Duel.Overlay(tc,g)
		end
	end
end

function s.indtg(e,c)
	return c:IsType(TYPE_XYZ) and c:GetOwner()==e:GetHandlerPlayer()
end

function s.auracon(e)
	return e:GetHandler():IsLocation(LOCATION_MZONE)
end
function s.atkval(e,c)
	return e:GetHandler():GetOverlayCount() * -500
end

function s.fdcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_OVERLAY)
		and c:GetPreviousLocation()==LOCATION_OVERLAY and c:IsControler(c:GetOwner())
end
function s.fdfilter(c,tp)
	return c:IsSetCard(SET_PURRFECT) and c:IsType(TYPE_FIELD) and not c:IsForbidden()
end
function s.fdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.fdfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,tp) end
end
function s.fdop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=Duel.SelectMatchingCard(tp,s.fdfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,tp)
	local tc=g:GetFirst()
	if tc then
		local fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
		if fc then
			Duel.SendtoGrave(fc,REASON_RULE)
		end
		Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
	end
end
