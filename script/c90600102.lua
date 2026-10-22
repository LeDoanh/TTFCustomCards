-- Æthel Nemesis Protocol - Initialization
-- ID: 90600102
local s,id=GetID()
local SETCODE_AETHEL_NEMESIS = 0x115A

function s.initial_effect(c)
	-- Hiệu ứng kích hoạt chính
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)

	-- Kích hoạt từ tay trong Standby Phase lượt đầu tiên của đối thủ (nếu đối thủ đi trước)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(s.handcon)
	c:RegisterEffect(e2)
end

s.listed_series={SETCODE_AETHEL_NEMESIS,SET_SKY_STRIKER}

--------------------------------------------------------------------------------
-- ĐIỀU KIỆN KÍCH HOẠT TỪ TAY
--------------------------------------------------------------------------------
function s.handcon(e)
	local tp=e:GetHandlerPlayer()
	return Duel.GetTurnCount()==1 and Duel.IsTurnPlayer(1-tp) and Duel.IsPhase(PHASE_STANDBY)
end

--------------------------------------------------------------------------------
-- COST VÀ TARGET
--------------------------------------------------------------------------------
function s.costfilter(c)
	return (c:IsSetCard(SETCODE_AETHEL_NEMESIS) or c:IsSetCard(SET_SKY_STRIKER))
		and c:IsSpell() and c:IsAbleToRemoveAsCost()
end

function s.spfilter(c,e,tp)
	return (c:IsSetCard(SETCODE_AETHEL_NEMESIS) or c:IsSetCard(SET_SKY_STRIKER))
		and c:IsMonster()
		and (c:IsLocation(LOCATION_DECK+LOCATION_GRAVE) or c:IsFaceup())
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_DECK,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED)
end

--------------------------------------------------------------------------------
-- OPERATION: SPECIAL SUMMON & LINK SUMMON NGAY SAU KHÍ RESOLVE
--------------------------------------------------------------------------------
function s.lkfilter(c,tp)
	return c:IsSetCard(SETCODE_AETHEL_NEMESIS) and c:IsLinkMonster() and c:IsLinkSummonable(tp)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- Ngay sau khi resolve, tiến hành Link Summon quái thú "Æthel-Nemesis"
		local lkg=Duel.GetMatchingGroup(s.lkfilter,tp,LOCATION_EXTRA,0,nil,tp)
		if #lkg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local lc=lkg:Select(tp,1,1,nil):GetFirst()
			Duel.LinkSummon(tp,lc,tp)
		end
	end
end