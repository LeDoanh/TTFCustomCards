-- Sky Striker Ace - Phantom
-- ID: 90600050
local s,id=GetID()
function s.initial_effect(c)
	-- Nguyên liệu Link: 3+ "Sky Striker" Monsters
	c:EnableReviveLimit()
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_SKY_STRIKER),3)

	-- Must first be Link Summoned
	local e0=Effect.CreateEffect(c)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(s.splimit)
	c:RegisterEffect(e0)

	-- Hiệu ứng 1: Quick Effect - Banish 3 Spells -> Negate toàn bộ bài ngửa mặt của đối thủ & Banish tối đa 3 lá ở GY/sân đối thủ
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E+TIMING_MAIN_END)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.negcost)
	e1:SetTarget(s.negtg)
	e1:SetOperation(s.negop)
	c:RegisterEffect(e1)

	-- Hiệu ứng 2: Nếu bị gửi xuống GY -> Special Summon tối đa 2 quái Level 4 "Sky Striker Ace" khác tên từ GY/Banish, rồi rút bài theo số Spell trong GY (max 3)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DRAW+CATEGORY_LEAVE_GRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end

s.listed_series={SET_SKY_STRIKER,SET_SKY_STRIKER_ACE}

--------------------------------------------------------------------------------
-- SUMMON LIMIT
--------------------------------------------------------------------------------
function s.splimit(e,se,sp,st)
	return (st&SUMMON_TYPE_LINK)==SUMMON_TYPE_LINK or not e:GetHandler():IsLocation(LOCATION_EXTRA)
end

--------------------------------------------------------------------------------
-- HIỆU ỨNG 1: NEGATE TOÀN BỘ SÂN ĐỐI THỦ & BANISH UP TO 3
--------------------------------------------------------------------------------
function s.cfilter(c)
	return c:IsSetCard(SET_SKY_STRIKER) and c:IsSpell() and c:IsAbleToRemoveAsCost()
end

function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,3,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,3,3,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end

function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsNegatable,tp,0,LOCATION_ONFIELD,1,nil) end
	local g=Duel.GetMatchingGroup(Card.IsNegatable,tp,0,LOCATION_ONFIELD,nil)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,#g,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_ONFIELD+LOCATION_GRAVE)
end

function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_ONFIELD,nil)
	local count=0
	for tc in aux.Next(g) do
		if not tc:IsDisabled() then
			Duel.NegateRelatedChain(tc,RESET_TURN_SET)
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e2)
			count=count+1
		end
	end
	
	if count>0 then
		local rm_g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,nil)
		if #rm_g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
			local sg=rm_g:Select(tp,1,3,nil)
			if #sg>0 then
				Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
			end
		end
	end
end

--------------------------------------------------------------------------------
-- HIỆU ỨNG 2: SPECIAL SUMMON UP TO 2 & DRAW CARDS
--------------------------------------------------------------------------------
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_SKY_STRIKER_ACE) and c:IsLevel(4)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	if ft>2 then ft=2 end
	
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil,e,tp)
	if #g==0 then return end
	
	local sg=aux.SelectUnselectGroup(g,e,tp,1,ft,aux.dncheck,1,tp,HINTMSG_SPSUMMON)
	if sg and #sg>0 and Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)>0 then
		local spell_ct=Duel.GetMatchingGroupCount(Card.IsSpell,tp,LOCATION_GRAVE,0,nil)
		if spell_ct>3 then spell_ct=3 end
		if spell_ct>0 and Duel.IsPlayerCanDraw(tp,spell_ct) then
			Duel.BreakEffect()
			Duel.Draw(tp,spell_ct,REASON_EFFECT)
		end
	end
end