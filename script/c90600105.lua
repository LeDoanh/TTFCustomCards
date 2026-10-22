-- Æthel Nemesis Ragnarok - Convergence
-- ID: 90600105
local s,id=GetID()
local SETCODE_AETHEL_NEMESIS = 0x115A

function s.initial_effect(c)
	-- Hiệu ứng 1: Gửi lá bài này từ tay xuống GY, sau đó banish 1 "Æthel-Nemesis" card từ tay
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.handcost)
	e1:SetTarget(s.handtg)
	e1:SetOperation(s.handop)
	c:RegisterEffect(e1)

	-- Hiệu ứng 2: Banish lá này từ GY (ngoại trừ lượt gửi xuống GY) -> Link Summon 1 quái thú Link "Æthel-Nemesis" 
	-- sử dụng các quái thú trên sân và/hoặc quái thú "Sky Striker" hay "Æthel-Nemesis" đang bị banish làm nguyên liệu.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E+TIMING_MAIN_END)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.lkcon)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.lktg)
	e2:SetOperation(s.lkop)
	c:RegisterEffect(e2)
end

s.listed_series={SETCODE_AETHEL_NEMESIS,SET_SKY_STRIKER}

--------------------------------------------------------------------------------
-- HIỆU ỨNG 1: GỬI TỪ TAY VÀO GY & BANISH 1 CARD TỪ TAY
--------------------------------------------------------------------------------
function s.rmfilter(c)
	return c:IsSetCard(SETCODE_AETHEL_NEMESIS) and c:IsAbleToRemove()
end

function s.handcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() end
	Duel.SendtoGrave(c,REASON_COST)
end

function s.handtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_HAND)
end

function s.handop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.rmfilter,tp,LOCATION_HAND,0,1,1,nil)
	if #g>0 then
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end

--------------------------------------------------------------------------------
-- HIỆU ỨNG 2: BANISH TỪ GY ĐỂ LINK SUMMON BẰNG SÂN + BANISH ZONE
--------------------------------------------------------------------------------
function s.lkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetTurnID()~=Duel.GetTurnCount()
end

function s.matfilter(c,lc,tp)
	if c:IsLocation(LOCATION_MZONE) then
		return c:IsCanBeLinkMaterial(lc,tp)
	elseif c:IsLocation(LOCATION_REMOVED) then
		return c:IsFaceup() and c:IsMonster() 
			and (c:IsSetCard(SETCODE_AETHEL_NEMESIS) or c:IsSetCard(SET_SKY_STRIKER))
			and c:IsCanBeLinkMaterial(lc,tp)
	end
	return false
end

function s.lkfilter(c,tp,mg)
	return c:IsSetCard(SETCODE_AETHEL_NEMESIS) and c:IsType(TYPE_LINK)
		and c:IsLinkSummonable(nil,mg)
end

function s.lktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local mg=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_MZONE+LOCATION_REMOVED,0,nil,nil,tp)
		return Duel.IsExistingMatchingCard(s.lkfilter,tp,LOCATION_EXTRA,0,1,nil,tp,mg)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function s.lkop(e,tp,eg,ep,ev,re,r,rp)
	local mg=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_MZONE+LOCATION_REMOVED,0,nil,nil,tp)
	local g=Duel.GetMatchingGroup(s.lkfilter,tp,LOCATION_EXTRA,0,nil,tp,mg)
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local lc=g:Select(tp,1,1,nil):GetFirst()
		Duel.LinkSummon(tp,lc,nil,mg)
	end
end