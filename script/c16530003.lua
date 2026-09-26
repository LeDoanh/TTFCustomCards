-- ============================================================
-- Card Name: Advance Cyberdark Keel
-- Passcode : 16530003
-- Type     : Monster / Effect
-- Attribute: DARK
-- Level    : 4
-- ATK/DEF  : 800 / 800
-- Race     : Machine
-- Archetype: Cyberdark (0x4093)
-- ============================================================
-- Effect 1: Target 1 Dragon/Machine in either GY; Special Summon
--           this card from hand/GY and equip that monster to it.
-- Effect 2: Gains ATK equal to the equipped Monster Card's ATK.
-- Effect 3: If sent to GY: Add 2 "Cyberdark" cards from Deck to hand,
--           then discard 2 cards.
-- You can only use each effect of "Advance Cyberdark Keel" once per turn.
-- ============================================================

local s,id=GetID()

function s.initial_effect(c)
	-- Special Summon from hand or GY and equip 1 Dragon/Machine from GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP+CATEGORY_LEAVE_GRAVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.igcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- Quick effect variant from GY if Cyberdark Cybernizing was activated
	local e1b=e1:Clone()
	e1b:SetType(EFFECT_TYPE_QUICK_O)
	e1b:SetCode(EVENT_FREE_CHAIN)
	e1b:SetRange(LOCATION_GRAVE)
	e1b:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E+TIMING_MAIN_END)
	e1b:SetCondition(s.quickcon)
	c:RegisterEffect(e1b)

	-- Gains ATK equal to the equipped Monster Card's ATK
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)

	-- Add 2 "Cyberdark" cards from Deck to hand then discard 2 cards
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_HANDES)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,{id,1})
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end

s.listed_series={SET_CYBERDARK}

function s.quickcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.HasFlagEffect(tp,16530006)
end

function s.igcon(e,tp,eg,ep,ev,re,r,rp)
	return not (e:GetHandler():IsLocation(LOCATION_GRAVE) and s.quickcon(e,tp,eg,ep,ev,re,r,rp))
end

function s.eqfilter(c)
	return c:IsRace(RACE_DRAGON|RACE_MACHINE) and c:IsMonster()
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and s.eqfilter(chkc) end
	local c=e:GetHandler()
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
			and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
			and Duel.IsExistingTarget(s.eqfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,c)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectTarget(tp,s.eqfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,c)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,tp,0)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		if tc and tc:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
			s.equipop(c,e,tp,tc)
		end
	end
end

function s.equipop(c,e,tp,tc)
	if not Duel.Equip(tp,tc,c,true) then return end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD)
	e1:SetValue(s.eqlimit)
	e1:SetLabelObject(c)
	tc:RegisterEffect(e1)
end

function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end

function s.atkfilter(c)
	return c:IsFaceup() and c:IsMonsterCard()
end

function s.atkval(e,c)
	local g=c:GetEquipGroup():Filter(s.atkfilter,nil)
	local val=0
	for tc in aux.Next(g) do
		local atk=tc:GetTextAttack()
		if atk>0 then val=val+atk end
	end
	return val
end

function s.thfilter(c)
	return c:IsSetCard(SET_CYBERDARK) and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,2,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,2)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,2,2,nil)
	if #g==2 and Duel.SendtoHand(g,nil,REASON_EFFECT)==2 then
		Duel.ConfirmCards(1-tp,g)
		Duel.ShuffleHand(tp)
		Duel.BreakEffect()
		Duel.DiscardHand(tp,nil,2,2,REASON_EFFECT+REASON_DISCARD)
	end
end
