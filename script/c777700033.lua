-- Gensokyo Nether - The Birth of Prismriver
-- ID: 777700033
local s,id=GetID()

local SET_GENSOKYO		   = 0xa70
local SET_GENSOKYO_NETHER	 = 0xd6c
local SET_PRISMRIVER		   = 0x1d6c -- Sub-setcode đại diện cho từ khóa "Prismriver"
local CARD_PRISMRIVER_SISTERS  = 777700032 -- Gensokyo Nether - Prismriver Sisters

s.listed_series={SET_GENSOKYO,SET_GENSOKYO_NETHER,SET_PRISMRIVER}
s.listed_names={CARD_PRISMRIVER_SISTERS}

function s.initial_effect(c)
	-- Hiệu ứng 1: Triệu hồi Đặc biệt tối đa 1 quái thú nhắc đến "Prismriver" trong text từ mỗi nơi (tay, Deck, Mộ),
	-- sau đó áp dụng 1 trong 2 hiệu ứng: giảm Level 1 quái vừa gọi về 2 HOẶC Synchro Summon "Gensokyo Nether - Prismriver Sisters"
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E+TIMING_MAIN_END)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)

	-- Hiệu ứng 2 (Quick Effect - Dưới Mộ): Trục xuất lá này, chọn 1 quái thú bạn điều khiển
	-- -> Giảm Level của nó về 2, đồng thời coi nó là Tuner trong lượt này
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E+TIMING_MAIN_END)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.lvtg)
	e2:SetOperation(s.lvop)
	c:RegisterEffect(e2)
end

--------------------------------------------------------------------------------
-- 1. LOGIC TRIỆU HỒI TỪ TAY / DECK / MỘ & CHỌN 1 TRONG 2 HIỆU ỨNG KÈM THEO
--------------------------------------------------------------------------------
function s.prism_check(c)
	return c:ListsArchetype(SET_PRISMRIVER) or c:ListsCodeWithArchetype(SET_PRISMRIVER) or c:IsSetCard(SET_PRISMRIVER)
end

function s.spfilter(c,e,tp)
	return c:IsType(TYPE_MONSTER) and s.prism_check(c) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end

function s.scfilter(c,mg)
	return c:IsCode(CARD_PRISMRIVER_SISTERS) and not c:IsPublic() and c:IsSynchroSummonable(nil,mg)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end

	local locs={LOCATION_HAND,LOCATION_DECK,LOCATION_GRAVE}
	local sg=Group.CreateGroup()
	for _,loc in ipairs(locs) do
		if ft<=0 then break end
		local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter),tp,loc,0,nil,e,tp)
		if #g>0 then
			local minc=(#sg==0 and loc==LOCATION_GRAVE) and 1 or 0
			local hint=HINTMSG_SPSUMMON
			Duel.Hint(HINT_SELECTMSG,tp,hint)
			local tc=g:Select(tp,minc,1,nil):GetFirst()
			if tc then
				sg:AddCard(tc)
				ft=ft-1
			end
		end
	end

	if #sg==0 then return end
	if Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)==0 then return end
	local og=Duel.GetOperatedGroup():Filter(Card.IsLocation,nil,LOCATION_MZONE)
	if #og==0 then return end

	local b1=og:IsExists(Card.HasLevel,1,nil)
	local b2=Duel.IsExistingMatchingCard(s.scfilter,tp,LOCATION_EXTRA,0,1,nil,og)
	if not (b1 or b2) then return end

	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,2)},
		{b2,aux.Stringid(id,3)})
	Duel.BreakEffect()
	if op==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
		local tc=og:FilterSelect(tp,Card.HasLevel,1,1,nil):GetFirst()
		if tc then
			Duel.HintSelection(tc)
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_LEVEL)
			e1:SetValue(2)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
	elseif op==2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
		local sc=Duel.SelectMatchingCard(tp,s.scfilter,tp,LOCATION_EXTRA,0,1,1,nil,og):GetFirst()
		if sc then
			Duel.ConfirmCards(1-tp,sc)
			Synchro.CheckAdditional=function(tp,mats,sync)
				return mats:FilterCount(function(mc) return og:IsContains(mc) end,nil)==#mats
			end
			Duel.SynchroSummon(tp,sc,nil,og)
			Synchro.CheckAdditional=nil
		end
	end
end

--------------------------------------------------------------------------------
-- 2. LOGIC DƯỚI MỘ: GIẢM LEVEL VỀ 2 & COI LÀ TUNER TRONG LƯỢT NÀY
--------------------------------------------------------------------------------
function s.lvfilter(c)
	return c:IsFaceup() and c:HasLevel() and (not c:IsLevel(2) or not c:IsType(TYPE_TUNER))
end

function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.lvfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.lvfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.lvfilter,tp,LOCATION_MZONE,0,1,1,nil)
end

function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local c=e:GetHandler()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_ADD_TYPE)
		e2:SetValue(TYPE_TUNER)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end