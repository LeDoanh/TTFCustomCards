-- Æthel Nemesis Entity - Absolute Singularity
-- ID: 90600084
local s,id=GetID()
local SETCODE_AETHEL_NEMESIS = 0x115A

--------------------------------------------------------------------------------
-- ĐIỀU KIỆN TRIỆU HỒI & KHÁNG HIỆU ỨNG (Định nghĩa trước để tránh lỗi nil)
--------------------------------------------------------------------------------
function s.splimit(e,se,sp,st)
	return (st&SUMMON_TYPE_LINK)==SUMMON_TYPE_LINK
end

function s.efilter(e,te)
	return te:GetOwner()~=e:GetHandler()
end

--------------------------------------------------------------------------------
-- INITIAL EFFECT
--------------------------------------------------------------------------------
function s.initial_effect(c)
	-- Nguyên liệu Link: 4+ "Æthel Nemesis" monsters
	c:EnableReviveLimit()
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,SETCODE_AETHEL_NEMESIS),4,8)

	-- Bắt buộc phải được Link Summoned trước (Must first be Link Summoned)
	local e0=Effect.CreateEffect(c)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(s.splimit)
	c:RegisterEffect(e0)

	-- Kháng tất cả hiệu ứng lá bài khác (Unaffected by other cards' effects)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetValue(s.efilter)
	c:RegisterEffect(e1)

	-- Hiệu ứng Quick Effect: Banish 3 "Æthel Nemesis" Spell từ Deck/GY -> Banish ngẫu nhiên 1 lá bài trên tay đối thủ ngửa mặt cho tới Standby Phase tiếp theo. 
	-- Nếu có 8+ Spell bị banish, đối thủ phải tự banish 2 lá từ tay hoặc trên sân (ngửa mặt).
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E+TIMING_MAIN_END)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.hcost)
	e2:SetTarget(s.htg)
	e2:SetOperation(s.hop)
	c:RegisterEffect(e2)

	-- Hiệu ứng khi rời sân: Nếu lá bài Link Summoned ngửa mặt này rời sân -> Special Summon tối đa 3 quái thú "Æthel-Nemesis" bị banish
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end

s.listed_series={SETCODE_AETHEL_NEMESIS}

--------------------------------------------------------------------------------
-- HIỆU ỨNG QUICK EFFECT: BANISH TAY ĐỐI THỦ + ÉP ĐỐI THỦ BANISH 2 LÁ
--------------------------------------------------------------------------------
function s.cfilter(c)
	return c:IsSetCard(SETCODE_AETHEL_NEMESIS) and c:IsSpell() and c:IsAbleToRemoveAsCost()
end

function s.hcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,3,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,3,3,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end

function s.htg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_HAND)
end

function s.hop(e,tp,eg,ep,ev,re,r,rp)
	local hg=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if #hg>0 then
		local sg=hg:RandomSelect(tp,1)
		local tc=sg:GetFirst()
		if tc and Duel.Remove(tc,POS_FACEDOWN,REASON_EFFECT)>0 then
			-- Trả lại tay đối thủ vào Standby Phase tiếp theo
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
			e1:SetCountLimit(1)
			e1:SetLabelObject(tc)
			e1:SetCondition(s.retcon)
			e1:SetOperation(s.retop)
			if Duel.GetCurrentPhase()==PHASE_STANDBY then
				e1:SetLabel(Duel.GetTurnCount())
			else
				e1:SetLabel(0)
			end
			Duel.RegisterEffect(e1,tp)
			tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
		end
	end

	-- Kiểm tra nếu có từ 8 Spell bị banish trở lên
	local banish_spells=Duel.GetMatchingGroup(function(c) return c:IsSpell() and c:IsFaceup() end,tp,LOCATION_REMOVED,0,nil)
	if #banish_spells>=8 then
		local og=Duel.GetMatchingGroup(function(c) 
			return (c:IsLocation(LOCATION_HAND) or c:IsFaceup()) and c:IsAbleToRemove(1-tp) 
		end,tp,0,LOCATION_HAND+LOCATION_ONFIELD,nil)
		
		if #og>=2 then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_REMOVE)
			local sg2=og:Select(1-tp,2,2,nil)
			Duel.Remove(sg2,POS_FACEUP,REASON_RULE)
		end
	end
end

function s.retcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffect(id)==0 then
		e:Reset()
		return false
	end
	return Duel.GetTurnCount()~=e:GetLabel()
end

function s.retop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	Duel.SendtoHand(tc,1-tp,REASON_EFFECT)
	e:Reset()
end

--------------------------------------------------------------------------------
-- HIỆU ỨNG KHI RỜI SÂN: SPECIAL SUMMON TỐI ĐA 3 QUÁI THÚ "ÆTHEL-NEMESIS" BỊ BANISH
--------------------------------------------------------------------------------
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_LINK) and c:IsPreviousControler(tp)
end

function s.spfilter(c,e,tp)
	return c:IsSetCard(SETCODE_AETHEL_NEMESIS) and c:IsMonster() and c:IsFaceup()
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_REMOVED)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	ft=math.min(ft,3)
	
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_REMOVED,0,1,ft,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end