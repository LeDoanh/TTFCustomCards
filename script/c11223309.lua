-- ============================================================
-- Card Name: Reploid Headquarter
-- Passcode : 11223309
-- Type     : Spell / Field
-- Archetype: None
-- ============================================================
-- Effect 1: "Maverick Hunter" monsters you control cannot be
--           banished by your opponent's card effects.
-- Effect 2: You can discard 1 card; Special Summon 1 "Maverick
--           Hunter" monster from your hand or GY.
-- Effect 3: If your opponent activates a card or effect: You can
--           shuffle 1 "Maverick Hunter" monster you control into
--           the Deck or Extra Deck; add to your hand or Special Summon
--           1 "Maverick Analyzer" monster from your Deck.
-- You can only use each effect of "Reploid Headquarter" once per turn.
-- ============================================================

Duel.LoadScript("constants.lua")
local s,id=GetID()

function s.initial_effect(c)
	-- ============================================================
	-- Activate Field Spell (optionally use Special Summon effect)
	-- ============================================================
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.acttg)
	e1:SetOperation(s.actop)
	c:RegisterEffect(e1)

	-- ============================================================
	-- Effect 1 — Continuous: Protection against opponent banishing
	-- ============================================================
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_REMOVE)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_MAVERICK_HUNTER))
	e2:SetValue(s.rmval)
	c:RegisterEffect(e2)

	-- ============================================================
	-- Effect 2 — Ignition: Discard 1; Special Summon from hand/GY
	-- ============================================================
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.spcon)
	e3:SetCost(s.spcost)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)

	-- ============================================================
	-- Effect 3 — Trigger on Opponent Chaining: Tag out Hunter for Analyzer
	-- ============================================================
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_TODECK+CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_CHAINING)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1,{id,1})
	e4:SetCondition(s.thspcon)
	e4:SetTarget(s.thsptg)
	e4:SetOperation(s.thspop)
	c:RegisterEffect(e4)
end

s.listed_series={SET_MAVERICK_HUNTER,SET_MAVERICK_ANALYZER}

-- ============================================================
-- Activation Logic
-- ============================================================
function s.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local is_copy=c:IsLocation(LOCATION_DECK) or e:GetHandler()~=c
	local b=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,c)
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp)
		and Duel.GetFlagEffect(tp,id)==0
	if chk==0 then
		if is_copy then return b end
		return true
	end
	if b and (is_copy or Duel.SelectYesNo(tp,aux.Stringid(id,0))) then
		e:SetLabel(1)
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
		Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
	else
		e:SetLabel(0)
	end
end

function s.actop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()~=1 then return end
	local c=e:GetHandler()
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) and c==e:GetOwner() and not c:IsRelateToEffect(e) then return end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

-- ============================================================
-- Effect 1 Logic
-- ============================================================
function s.rmval(e,re,rp)
	return rp==1-e:GetHandlerPlayer()
end

-- ============================================================
-- Effect 2 Logic
-- ============================================================
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(tp,id)==0
end

function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end

function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_MAVERICK_HUNTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

-- ============================================================
-- Effect 3 Logic
-- ============================================================
function s.thspcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp
end

function s.tdfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_MAVERICK_HUNTER) and (c:IsAbleToDeck() or c:IsAbleToExtra())
end

function s.anfilter(c,e,tp,chk_sp)
	if not (c:IsSetCard(SET_MAVERICK_ANALYZER) and c:IsType(TYPE_MONSTER)) then return false end
	return c:IsAbleToHand() or (chk_sp and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end

function s.thsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local chk_sp=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	if chk==0 then return Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingMatchingCard(s.anfilter,tp,LOCATION_DECK,0,1,nil,e,tp,chk_sp) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_MZONE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end

function s.analyzer_mon(c)
	return c:IsSetCard(SET_MAVERICK_ANALYZER) and c:IsType(TYPE_MONSTER)
end

function s.an_thfilter(c)
	return s.analyzer_mon(c) and c:IsAbleToHand()
end

function s.an_spfilter(c,e,tp)
	return s.analyzer_mon(c) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.thspop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_MZONE,0,1,1,nil)
	if #g>0 and Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 then
		local b1=Duel.IsExistingMatchingCard(s.an_thfilter,tp,LOCATION_DECK,0,1,nil)
		local b2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.an_spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
		if not (b1 or b2) then return end
		local opt=0
		if b1 and b2 then
			opt=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))
		elseif b1 then
			opt=0
		else
			opt=1
		end
		if opt==0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local sg=Duel.SelectMatchingCard(tp,s.an_thfilter,tp,LOCATION_DECK,0,1,1,nil)
			if #sg>0 then
				Duel.SendtoHand(sg,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,sg)
			end
		else
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sg=Duel.SelectMatchingCard(tp,s.an_spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
			if #sg>0 then
				Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end
