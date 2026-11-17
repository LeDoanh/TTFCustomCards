-- Gensokyo Nether - Prismriver Sisters
-- ID: 777700032
local s,id=GetID()

local SET_GENSOKYO		= 0xa70
local SET_GENSOKYO_NETHER = 0xd6c
local SET_PRISMRIVER	  = 0x1d6c -- Sub-setcode đại diện cho từ khóa "Prismriver"

s.listed_series={SET_GENSOKYO,SET_GENSOKYO_NETHER,SET_PRISMRIVER}

function s.initial_effect(c)
	-- Quy tắc Triệu hồi Đồng bộ: 1 Tuner + 2+ non-Tuner "Gensokyo" (bao gồm ít nhất 1 quái có nhắc đến "Prismriver" trong text)
	c:EnableReviveLimit()
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTunerEx(Card.IsSetCard,SET_GENSOKYO),2,99,s.matfilter)

	-- Hiệu ứng 1: Khi được Triệu hồi Đồng bộ -> Triệu hồi Đặc biệt các quái thú đã dùng làm nguyên liệu Synchro cho lá này, nhưng vô hiệu hóa hiệu ứng của chúng
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)

	-- Hiệu ứng 2 (Quick Effect - Tối đa 2 lần/lượt): Chọn 2 quái thú trên sân (bao gồm 1 quái "Gensokyo Nether" bạn điều khiển)
	-- -> Ngay sau khi giải quyết, Triệu hồi Đồng bộ 1 quái thú chỉ dùng 2 quái được chọn làm nguyên liệu
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E+TIMING_MAIN_END)
	e2:SetCountLimit(2,id)
	e2:SetTarget(s.syntg)
	e2:SetOperation(s.synop)
	c:RegisterEffect(e2)

	-- Hiệu ứng 3: Nếu lá bài này bị gửi xuống Mộ -> Trong End Phase, đẩy toàn bộ bài trên sân về tay
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetOperation(s.regop)
	c:RegisterEffect(e3)
end

--------------------------------------------------------------------------------
-- 1. BỘ LỌC NGUYÊN LIỆU ĐỒNG BỘ (PHẢI CÓ ÍT NHẤT 1 QUÁI NHẮC ĐẾN "PRISMRIVER")
--------------------------------------------------------------------------------
function s.prism_check(c)
	return c:ListsArchetype(SET_PRISMRIVER) or c:ListsCodeWithArchetype(SET_PRISMRIVER) or c:IsSetCard(SET_PRISMRIVER)
end

function s.matfilter(c,scard,sumtype,tp)
	return s.prism_check(c)
end

--------------------------------------------------------------------------------
-- 2. LOGIC HỒI SINH TOÀN BỘ NGUYÊN LIỆU SYNCHRO KHI ĐƯỢC TRIỆU HỒI ĐỒNG BỘ
--------------------------------------------------------------------------------
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end

function s.mgfilter(c,e,tp,sc)
	return c:IsControler(tp) and c:IsLocation(LOCATION_GRAVE)
		and (c:GetReason()&0x80008)==0x80008 and c:GetReasonCard()==sc
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local mg=c:GetMaterial()
	local ct=#mg
	if chk==0 then
		return ct>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>=ct
			and (ct==1 or not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT))
			and mg:FilterCount(s.mgfilter,nil,e,tp,c)==ct
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,mg,ct,tp,LOCATION_GRAVE)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local mg=c:GetMaterial()
	local ct=#mg
	if ct==0 or Duel.GetLocationCount(tp,LOCATION_MZONE)<ct then return end
	if ct>1 and Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return end
	if mg:FilterCount(aux.NecroValleyFilter(s.mgfilter),nil,e,tp,c)~=ct then return end
	for tc in aux.Next(mg) do
		if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
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
		end
	end
	Duel.SpecialSummonComplete()
end

--------------------------------------------------------------------------------
-- 3. LOGIC QUICK EFFECT TARGET 2 QUÁI TRÊN SÂN -> SYNCHRO SUMMON NGAY LẬP TỨC
--------------------------------------------------------------------------------
function s.synfilter(c,mg)
	return c:IsSynchroSummonable(nil,mg)
end

function s.rescon(sg,e,tp,mg)
	return sg:IsExists(s.own_nether,1,nil,tp)
		and Duel.IsExistingMatchingCard(s.synfilter,tp,LOCATION_EXTRA,0,1,nil,sg)
end

function s.own_nether(c,tp)
	return c:IsControler(tp) and c:IsFaceup() and c:IsSetCard(SET_GENSOKYO_NETHER)
end

function s.syntg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local g=Duel.GetMatchingGroup(Card.IsCanBeEffectTarget,tp,LOCATION_MZONE,LOCATION_MZONE,nil,e)
	if chk==0 then return aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,0) end
	local sg=aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,1,tp,HINTMSG_TARGET)
	Duel.SetTargetCard(sg)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function s.synop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	if #tg~=2 then return end
	Synchro.CheckAdditional=function(tp,sg,sc) return #sg==2 and sg:IsContains(tg:GetFirst()) and sg:IsContains(tg:GetNext()) end
	local syng=Duel.GetMatchingGroup(s.synfilter,tp,LOCATION_EXTRA,0,nil,tg)
	if #syng>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sc=syng:Select(tp,1,1,nil):GetFirst()
		Duel.SynchroSummon(tp,sc,nil,tg)
	end
	Synchro.CheckAdditional=nil
end

--------------------------------------------------------------------------------
-- 4. LOGIC ĐẨY TOÀN BỘ BÀI TRÊN SÂN VỀ TAY VÀO END PHASE KHI RƠI XUỐNG MỘ
--------------------------------------------------------------------------------
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetOperation(s.thop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if #g>0 then
		Duel.Hint(HINT_CARD,0,id)
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end