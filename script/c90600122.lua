-- Convergence of the Elemental Realms
-- ID: 90600122
local s,id=GetID()

function s.initial_effect(c)
	-- Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,3,e:GetHandler()) end
	Duel.DiscardHand(tp,Card.IsDiscardable,3,3,REASON_COST+REASON_DISCARD,e:GetHandler())
end

function s.thfilter(c)
	return c:IsMonster() and c:IsAbleToHand()
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if not (tc and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_HAND)) then return end
	Duel.ConfirmCards(1-tp,tc)
	Duel.ShuffleHand(tp)

	local c=e:GetHandler()
	local att=tc:GetAttribute()

	-- ● LIGHT or DARK: Target 1 card in your GY; add it to your hand.
	if (att&(ATTRIBUTE_LIGHT|ATTRIBUTE_DARK))~=0 then
		if Duel.IsExistingMatchingCard(aux.NecroValleyFilter(Card.IsAbleToHand),tp,LOCATION_GRAVE,0,1,nil) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(Card.IsAbleToHand),tp,LOCATION_GRAVE,0,1,1,nil)
			if #sg>0 then
				Duel.SendtoHand(sg,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,sg)
			end
		end
	end

	-- ● DIVINE: You can conduct 1 Normal Summon/Set during your Main Phase this turn, in addition to your Normal Summon/Set. (You can only gain this effect once per turn.)
	if (att&ATTRIBUTE_DIVINE)~=0 then
		if Duel.GetFlagEffect(tp,id)==0 then
			Duel.BreakEffect()
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(aux.Stringid(id,1))
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetTargetRange(LOCATION_HAND|LOCATION_MZONE,0)
			e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
			e1:SetReset(RESET_PHASE|PHASE_END)
			Duel.RegisterEffect(e1,tp)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_EXTRA_SET_COUNT)
			Duel.RegisterEffect(e2,tp)
			Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
		end
	end

	-- ● EARTH, WATER, FIRE, or WIND: Special Summon that added monster, but its effects are negated, also destroy it during the End Phase.
	if (att&(ATTRIBUTE_EARTH|ATTRIBUTE_WATER|ATTRIBUTE_FIRE|ATTRIBUTE_WIND))~=0 then
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false) then
			Duel.BreakEffect()
			if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
				-- Negate effects
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_DISABLE)
				e1:SetReset(RESET_EVENT|RESETS_STANDARD)
				tc:RegisterEffect(e1)
				local e2=e1:Clone()
				e2:SetCode(EFFECT_DISABLE_EFFECT)
				tc:RegisterEffect(e2)
				-- Destroy during the End Phase
				tc:RegisterFlagEffect(id,RESETS_STANDARD_PHASE_END,0,1)
				Duel.SpecialSummonComplete()
				local e3=Effect.CreateEffect(c)
				e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
				e3:SetCode(EVENT_PHASE+PHASE_END)
				e3:SetCountLimit(1)
				e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
				e3:SetLabelObject(tc)
				e3:SetReset(RESET_PHASE|PHASE_END)
				e3:SetCondition(s.descon)
				e3:SetOperation(s.desop)
				Duel.RegisterEffect(e3,tp)
			end
		end
	end
end

function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffect(id)~=0 then
		return true
	else
		e:Reset()
		return false
	end
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	Duel.Destroy(tc,REASON_EFFECT)
end
