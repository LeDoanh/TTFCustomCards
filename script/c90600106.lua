-- Æthel Nemesis - Obliteration
-- ID: 90600106
local s,id=GetID()
local SETCODE_AETHEL_NEMESIS = 0x115A

function s.initial_effect(c)
	-- Hiệu ứng 1: Trong Main Phase: Target 1 face-up monster đối thủ -> Phủ nhận hiệu ứng + Không thể làm nguyên liệu Fusion, Synchro, Xyz, Link
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)

	-- Điều kiện kích hoạt từ tay trong lượt đối thủ (Nếu có 3+ lá bài "Æthel Nemesis" và/hoặc "Sky Striker" bị banish)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_QP_ACT_IN_NTH_HAND)
	e2:SetCondition(s.handcon)
	c:RegisterEffect(e2)

	-- Hiệu ứng 2: Trong Main Phase của bạn (trừ lượt gửi xuống GY): Banish lá này từ GY -> Special Summon 1 "Æthel Nemesis" hoặc "Sky Striker" monster từ Banish Zone
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(s.spcon)
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end

s.listed_series={SETCODE_AETHEL_NEMESIS,SET_SKY_STRIKER}

--------------------------------------------------------------------------------
-- KIỂM TRA ĐIỀU KIỆN KÍCH HOẠT TỪ TAY TRONG LƯỢT ĐỐI THỦ
--------------------------------------------------------------------------------
function s.handfilter(c)
	return (c:IsSetCard(SETCODE_AETHEL_NEMESIS) or c:IsSetCard(SET_SKY_STRIKER)) and c:IsFaceup()
end

function s.handcon(e)
	local tp=e:GetHandlerPlayer()
	return Duel.IsTurnPlayer(1-tp) 
		and Duel.GetMatchingGroupCount(s.handfilter,tp,LOCATION_REMOVED,0,nil)>=3
end

--------------------------------------------------------------------------------
-- HIỆU ỨNG 1: TARGET 1 QUÁI THỦ ĐỐI THỦ & VÔ HIỆU HÓA/CẤM LÀM NGUYÊN LIỆU
--------------------------------------------------------------------------------
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsMainPhase()
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() and not tc:IsImmuneToEffect(e) then
		-- Phủ nhận hiệu ứng
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

		-- Không thể dùng làm nguyên liệu Fusion
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetValue(1)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e3)

		-- Không thể dùng làm nguyên liệu Synchro
		local e4=e3:Clone()
		e4:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
		tc:RegisterEffect(e4)

		-- Không thể dùng làm nguyên liệu Xyz
		local e5=e3:Clone()
		e5:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
		tc:RegisterEffect(e5)

		-- Không thể dùng làm nguyên liệu Link
		local e6=e3:Clone()
		e6:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
		tc:RegisterEffect(e6)
	end
end

--------------------------------------------------------------------------------
-- HIỆU ỨNG 2: SPECIAL SUMMON TỪ BANISH ZONE KHI BANISH TỪ GY
--------------------------------------------------------------------------------
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsMainPhase() and e:GetHandler():GetTurnID()~=Duel.GetTurnCount()
end

function s.spfilter(c,e,tp)
	return (c:IsSetCard(SETCODE_AETHEL_NEMESIS) or c:IsSetCard(SET_SKY_STRIKER))
		and c:IsMonster() and c:IsFaceup()
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_REMOVED)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end