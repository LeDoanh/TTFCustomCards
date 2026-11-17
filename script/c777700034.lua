-- Gensokyo Nether - Youmu the Soulsword
-- ID: 777700034
local s,id=GetID()

local SET_GENSOKYO		= 0xa70
local SET_GENSOKYO_NETHER = 0xd6c

s.listed_series={SET_GENSOKYO,SET_GENSOKYO_NETHER}

function s.initial_effect(c)
	-- Quy tắc Triệu hồi Đồng bộ: 1 Tuner + 1+ non-Tuner "Gensokyo"
	c:EnableReviveLimit()
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTunerEx(Card.IsSetCard,SET_GENSOKYO),1,99)

	-- Hiệu ứng 1: Khi được Triệu hồi Đồng bộ -> Chọn 1 lá bài đối thủ điều khiển; vô hiệu hóa hiệu ứng của nó
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.negcon)
	e1:SetTarget(s.negtg)
	e1:SetOperation(s.negop)
	c:RegisterEffect(e1)

	-- Hiệu ứng 2 (Quick Effect - Trong lượt đối thủ): Trả lá bài này về Extra Deck,
	-- sau đó Triệu hồi Đặc biệt 1 Tuner "Gensokyo" và 1 non-Tuner "Gensokyo" từ tay/Deck/Mộ/trục xuất
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOEXTRA+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E+TIMING_MAIN_END+TIMING_BATTLE_START)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)

	-- Hiệu ứng 3: Nếu lá bài này được dùng làm nguyên liệu Triệu hồi Đồng bộ
	-- -> Gửi 1 lá "Gensokyo Nether" từ Deck xuống Mộ
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetCountLimit(1,{id,2})
	e3:SetCondition(s.tgcon)
	e3:SetTarget(s.tgtg)
	e3:SetOperation(s.tgop)
	c:RegisterEffect(e3)
end

--------------------------------------------------------------------------------
-- 1. LOGIC VÔ HIỆU HÓA HIỆU ỨNG 1 LÁ BÀI ĐỐI THỦ ĐIỀU KHIỂN KHI SYNCHRO SUMMON
--------------------------------------------------------------------------------
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end

function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and chkc:IsNegatable() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsNegatable,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
	local g=Duel.SelectTarget(tp,Card.IsNegatable,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end

function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() and not tc:IsDisabled() then
		local c=e:GetHandler()
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		if tc:IsType(TYPE_TRAPMONSTER) then
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e3)
		end
	end
end

--------------------------------------------------------------------------------
-- 2. LOGIC TRẢ VỀ EXTRA DECK -> TRIỆU HỒI 1 TUNER & 1 NON-TUNER "GENSOKYO"
--------------------------------------------------------------------------------
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==1-tp
end

function s.tunfilter(c,e,tp)
	return c:IsSetCard(SET_GENSOKYO) and c:IsType(TYPE_MONSTER) and c:IsType(TYPE_TUNER)
		and (not c:IsLocation(LOCATION_REMOVED) or c:IsFaceup())
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.nontunfilter(c,e,tp)
	return c:IsSetCard(SET_GENSOKYO) and c:IsType(TYPE_MONSTER) and not c:IsType(TYPE_TUNER)
		and (not c:IsLocation(LOCATION_REMOVED) or c:IsFaceup())
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local loc=LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED
	if chk==0 then
		return c:IsAbleToExtra()
			and Duel.GetMZoneCount(tp,c)>=2
			and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
			and Duel.IsExistingMatchingCard(s.tunfilter,tp,loc,0,1,nil,e,tp)
			and Duel.IsExistingMatchingCard(s.nontunfilter,tp,loc,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,c,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,loc)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)==0 or not c:IsLocation(LOCATION_EXTRA) then return end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 or Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return end
	local loc=LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED
	local g1=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.tunfilter),tp,loc,0,nil,e,tp)
	local g2=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.nontunfilter),tp,loc,0,nil,e,tp)
	if #g1>0 and #g2>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg1=g1:Select(tp,1,1,nil)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg2=g2:Select(tp,1,1,nil)
		sg1:Merge(sg2)
		Duel.SpecialSummon(sg1,0,tp,tp,false,false,POS_FACEUP)
	end
end

--------------------------------------------------------------------------------
-- 3. LOGIC FOOLISH BURIAL 1 LÁ "GENSOKYO NETHER" TỪ DECK KHI LÀM NGUYÊN LIỆU SYNCHRO
--------------------------------------------------------------------------------
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return (r&REASON_SYNCHRO)~=0
end

function s.tgfilter(c)
	return c:IsSetCard(SET_GENSOKYO_NETHER) and c:IsAbleToGrave()
end

function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end

function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end