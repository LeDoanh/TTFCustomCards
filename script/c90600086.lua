-- Sky Striker Nemesis - Astraea
-- ID: 90600086
local s,id=GetID()
local SETCODE_AETHEL_NEMESIS = 0x115A

function s.initial_effect(c)
	-- Nguyên liệu Link: 1 "Æthel-Nemesis" or "Sky Striker" monster
	c:EnableReviveLimit()
	Link.AddProcedure(c,s.mfilter,1,1)

	-- Hiệu ứng 1: Khi được Special Summon -> Banish 1 Spell "Æthel Nemesis" từ Deck hoặc GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.rmtg)
	e1:SetOperation(s.rmop)
	c:RegisterEffect(e1)

	-- Hiệu ứng 2 (Quick Effect trong Main Phase của bạn): Banish lá này từ GY -> Special Summon 1 quái thú "Sky Striker Ace" từ Extra Deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E+TIMING_MAIN_END)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.exspcon)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.exsptg)
	e2:SetOperation(s.exspop)
	c:RegisterEffect(e2)
end

s.listed_series={SETCODE_AETHEL_NEMESIS,SET_SKY_STRIKER,SET_SKY_STRIKER_ACE}

--------------------------------------------------------------------------------
-- NGUYÊN LIỆU LINK
--------------------------------------------------------------------------------
function s.mfilter(c,lc,sumtype,tp)
	return c:IsSetCard(SETCODE_AETHEL_NEMESIS,lc,sumtype,tp) or c:IsSetCard(SET_SKY_STRIKER,lc,sumtype,tp)
end

--------------------------------------------------------------------------------
-- HIỆU ỨNG 1: BANISH SPELL "ÆTHEL NEMESIS" TỪ DECK/GY
--------------------------------------------------------------------------------
function s.rmfilter(c)
	return c:IsSetCard(SETCODE_AETHEL_NEMESIS) and c:IsSpell() and c:IsAbleToRemove()
end

function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end

function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.rmfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end

--------------------------------------------------------------------------------
-- HIỆU ỨNG 2: BANISH TỪ GY ĐỂ SPECIAL SUMMON QUÁI "SKY STRIKER ACE" TỪ EXTRA DECK
--------------------------------------------------------------------------------
function s.exspcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsMainPhase() and Duel.IsTurnPlayer(tp)
end

function s.exspfilter(c,e,tp)
	return c:IsSetCard(SET_SKY_STRIKER_ACE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end

function s.exsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.exspfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function s.exspop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.exspfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end