-- Æthel Nemesis Assimilation - Re-Code
-- ID: 90600096
local s,id=GetID()
local SETCODE_AETHEL_NEMESIS = 0x115A

function s.initial_effect(c)
	-- Hiệu ứng kích hoạt: Banish 1 monster (cost) -> Special Summon 1 "Æthel-Nemesis" monster từ Banish Zone
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

s.listed_series={SETCODE_AETHEL_NEMESIS}

--------------------------------------------------------------------------------
-- KIỂM TRA ĐIỀU KIỆN COST & TARGET
--------------------------------------------------------------------------------
function s.spfilter(c,e,tp)
	return c:IsSetCard(SETCODE_AETHEL_NEMESIS) and c:IsMonster() and c:IsFaceup()
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.cfilter(c,tp,has_spells)
	if not (c:IsMonster() and c:IsFaceup() and c:IsAbleToRemoveAsCost()) then return false end
	if c:IsControler(tp) then
		return true
	else
		return has_spells and c:IsControler(1-tp)
	end
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local has_spells=Duel.GetMatchingGroupCount(Card.IsSpell,tp,LOCATION_REMOVED,0,nil)>=3
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tp,has_spells) end
	
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tp,has_spells)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_REMOVED)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end