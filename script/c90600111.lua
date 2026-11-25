-- Sky Striker Maneuver - Sangen Burst
-- ID: 90600111
local s,id=GetID()
local SET_SKY_STRIKER   = 0x115
local SET_SANGEN        = 0x1a2
local SET_TENPAI_DRAGON = 0x1a1

function s.initial_effect(c)
	-- Treated as a "Sangen" card
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_ADD_SETCODE)
	e0:SetValue(SET_SANGEN)
	c:RegisterEffect(e0)

	-- Activate 1 of these effects
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E+TIMING_MAIN_END)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

s.listed_series={SET_SKY_STRIKER,SET_SANGEN,SET_TENPAI_DRAGON}

function s.thfilter1(c)
	return c:IsMonster() and (c:IsSetCard(SET_SKY_STRIKER) or c:IsSetCard(SET_TENPAI_DRAGON)) and c:IsAbleToHand()
end

function s.tgfilter2(c)
	return c:IsFaceup() and (c:IsSetCard(SET_TENPAI_DRAGON) or (c:IsRace(RACE_MACHINE) and c:IsType(TYPE_SYNCHRO)))
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.tgfilter2(chkc) end
	local b1=Duel.IsExistingMatchingCard(s.thfilter1,tp,LOCATION_DECK,0,1,nil)
	local b2=Duel.IsExistingTarget(s.tgfilter2,tp,LOCATION_MZONE,0,1,nil)
	if chk==0 then return b1 or b2 end

	local op=0
	if b1 and b2 then
		op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))
	elseif b1 then
		op=Duel.SelectOption(tp,aux.Stringid(id,1))
	else
		op=Duel.SelectOption(tp,aux.Stringid(id,2))+1
	end
	e:SetLabel(op)

	if op==0 then
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SUMMON)
		e:SetProperty(0)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	else
		e:SetCategory(CATEGORY_ATKCHANGE)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
		Duel.SelectTarget(tp,s.tgfilter2,tp,LOCATION_MZONE,0,1,1,nil)
	end
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==0 then
		-- Add 1 "Sky Striker" or "Tenpai Dragon" monster from Deck to hand
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.thfilter1,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 and g:GetFirst():IsLocation(LOCATION_HAND) then
			Duel.ConfirmCards(1-tp,g)
			-- If 3+ Spells in GY, can Normal Summon 1 monster from hand
			local sg=Duel.GetMatchingGroup(Card.IsSummonable,tp,LOCATION_HAND,0,nil,true,nil)
			if Duel.GetMatchingGroupCount(Card.IsSpell,tp,LOCATION_GRAVE,0,nil)>=3
				and #sg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
				Duel.BreakEffect()
				Duel.ShuffleHand(tp)
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
				local sc=sg:Select(tp,1,1,nil):GetFirst()
				if sc then
					Duel.Summon(tp,sc,true,nil)
				end
			end
		end
	else
		-- Target gains 300 ATK per Spell in GY, and is unaffected by opponent's activated effects
		local tc=Duel.GetFirstTarget()
		if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
			local ct=Duel.GetMatchingGroupCount(Card.IsSpell,tp,LOCATION_GRAVE,0,nil)
			if ct>0 then
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_UPDATE_ATTACK)
				e1:SetValue(ct*300)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				tc:RegisterEffect(e1)
			end
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetDescription(aux.Stringid(id,4))
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetProperty(EFFECT_FLAG_CLIENT_HINT)
			e2:SetCode(EFFECT_IMMUNE_EFFECT)
			e2:SetValue(s.efilter)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			e2:SetOwnerPlayer(tp)
			tc:RegisterEffect(e2)
		end
	end
end

function s.efilter(e,te)
	return te:GetOwnerPlayer()==1-e:GetHandlerPlayer() and te:IsActivated()
end
