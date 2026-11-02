--Veilstrike the Scarlet Warrior
local s,id=GetID()
local SET_VEILSTRIKE=0x7f1
s.listed_series={SET_VEILSTRIKE}
function s.initial_effect(c)
	--Gain ATK each time its controller activates a Veilstrike Trap Card.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.atkcon)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_HAND|LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,0})
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E|TIMING_END_PHASE)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return rp==1-tp and Duel.IsChainNegatable(ev) end)
	e3:SetCost(s.negcost)
	e3:SetTarget(s.negtg)
	e3:SetOperation(s.negop)
	c:RegisterEffect(e3)
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==tp and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsTrapEffect()
		and re:GetHandler():IsSetCard(SET_VEILSTRIKE)
end
function s.atkop(e,tp,eg,ep,ev)
	local c=e:GetHandler()
	local gain=Effect.CreateEffect(c)
	gain:SetType(EFFECT_TYPE_SINGLE)
	gain:SetCode(EFFECT_UPDATE_ATTACK)
	gain:SetValue(300)
	gain:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE)
	c:RegisterEffect(gain)
	--An activation that is negated does not count as an activated Trap Card.
	local rollback=Effect.CreateEffect(c)
	rollback:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	rollback:SetCode(EVENT_CHAIN_NEGATED)
	rollback:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	rollback:SetLabel(ev)
	rollback:SetLabelObject(gain)
	rollback:SetCondition(function(e,tp,eg,ep,ev) return ev==e:GetLabel() end)
	rollback:SetOperation(function(e)
		local ge=e:GetLabelObject()
		if ge and not ge:IsDeleted() then ge:Reset() end
	end)
	rollback:SetReset(RESET_CHAIN)
	Duel.RegisterEffect(rollback,tp)
end
function s.disfilter(c)
	return c:IsSetCard(SET_VEILSTRIKE) and c:IsDiscardable()
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.disfilter,tp,LOCATION_HAND,0,1,nil) end
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
	local g=Duel.SelectMatchingCard(tp,s.disfilter,tp,LOCATION_HAND,0,1,1,nil)
	local discard_self=g:IsContains(c)
	Duel.SendtoGrave(g,REASON_COST|REASON_DISCARD)
	--The text does not say "other": this card may discard itself from hand.
	if discard_self and c:IsLocation(LOCATION_GRAVE) then c:CreateEffectRelation(e) end
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,c:GetLocation())
end
function s.spop(e,tp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsLocation(LOCATION_HAND|LOCATION_GRAVE)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.disfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
	local g=Duel.SelectMatchingCard(tp,s.disfilter,tp,LOCATION_HAND,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST|REASON_DISCARD)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsRelateToEffect(re) and re:GetHandler():IsDestructable() then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function s.negop(e,tp,eg,ep,ev,re)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
