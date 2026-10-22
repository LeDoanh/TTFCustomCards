-- Aethel Nemesis Corrupter - Shadow Ace
-- ID: 90600076
local s,id=GetID()
local SETCODE_AETHEL_NEMESIS = 0x115A

function s.initial_effect(c)
	-- Luôn được coi là lá bài "Sky Striker Ace - Raye"
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_ADD_CODE)
	e0:SetValue(26077387) -- Code gốc của Sky Striker Ace - Raye
	c:RegisterEffect(e0)

	-- Hiệu ứng 1: Nếu quái Link "Aethel-Nemesis" hoặc "Sky Striker" bạn điều khiển bị gửi xuống GY hoặc bị banish -> Special Summon từ tay hoặc GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e2)

	-- Hiệu ứng 2 (Quick Effect trong Main Phase): Banish lá này từ sân và 1 Spell từ GY -> Special Summon 1 quái Link "Aethel-Nemesis" hoặc "Sky Striker Ace" từ Extra Deck/Banish Zone vào Main Monster Zone
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E+TIMING_MAIN_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(s.exspcon)
	e3:SetCost(s.exspcost)
	e3:SetTarget(s.exsptg)
	e3:SetOperation(s.exspop)
	c:RegisterEffect(e3)
end

s.listed_names={26077387} -- Sky Striker Ace - Raye
s.listed_series={SETCODE_AETHEL_NEMESIS,SET_SKY_STRIKER,SET_SKY_STRIKER_ACE}

--------------------------------------------------------------------------------
-- HIỆU ỨNG 1: SPECIAL SUMMON TỪ TAY HOẶC GY
--------------------------------------------------------------------------------
function s.cfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsType(TYPE_LINK)
		and (c:IsSetCard(SETCODE_AETHEL_NEMESIS) or c:IsSetCard(SET_SKY_STRIKER))
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end

--------------------------------------------------------------------------------
-- HIỆU ỨNG 2: QUICK EFFECT BANISH TỪ SÂN & SPELL TỪ GY ĐỂ TRIỆU HỒI QUÁI LINK
--------------------------------------------------------------------------------
function s.exspcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsMainPhase()
end

function s.costfilter(c)
	return c:IsSpell() and c:IsAbleToRemoveAsCost()
end

function s.exspcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemoveAsCost()
		and Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	g:AddCard(c)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end

function s.exspfilter(c,e,tp)
	local is_valid_card = (c:IsSetCard(SETCODE_AETHEL_NEMESIS) or c:IsSetCard(SET_SKY_STRIKER_ACE)) and c:IsType(TYPE_LINK)
	if not is_valid_card or not c:IsCanBeSpecialSummoned(e,0,tp,false,false) then return false end
	
	-- Chỉ cho phép triệu hồi vào Main Monster Zone
	if c:IsLocation(LOCATION_EXTRA) then
		return Duel.GetLocationCountFromEx(tp,tp,nil,c,0x1f)>0
	else
		return c:IsFaceup() and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	end
end

function s.exsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.exspfilter,tp,LOCATION_EXTRA+LOCATION_REMOVED,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA+LOCATION_REMOVED)
end

function s.exspop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.exspfilter,tp,LOCATION_EXTRA+LOCATION_REMOVED,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end