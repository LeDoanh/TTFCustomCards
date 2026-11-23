-- Gensokyo Spell Sign Fantasy Seal
-- ID: 777700004
local s,id=GetID()

local SET_GENSOKYO = 0xa70
local CARD_REIMU   = 777700001 -- Gensokyo Shrine Maiden - Reimu Hakurei

s.listed_series={SET_GENSOKYO}
s.listed_names={CARD_REIMU}

function s.initial_effect(c)
	-- Hiệu ứng 1: Trục xuất 1 lá của đối thủ, vô hiệu hóa hiệu ứng và cấm kích hoạt bài trùng tên gốc đến hết lượt
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e1:SetCountLimit(1,id) -- Dùng chung HOPT với Hiệu ứng 2 (chỉ được xài 1 trong 2 hiệu ứng mỗi lượt)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)

	-- Hiệu ứng 2: Trục xuất lá này từ Mộ -> Lấy lại 1 quái thú "Gensokyo" đang bị trục xuất lên tay
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id) -- Dùng chung HOPT với Hiệu ứng 1
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end

--------------------------------------------------------------------------------
-- 1. LOGIC TRỤC XUẤT + VÔ HIỆU HÓA + KHÓA TÊN GỐC (SPELL SPEED 4 NẾU CÓ REIMU)
--------------------------------------------------------------------------------
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_GENSOKYO),tp,LOCATION_MZONE,0,1,nil)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and chkc:IsAbleToRemove() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
	-- Nếu điều khiển "Gensokyo Shrine Maiden - Reimu Hakurei", đối thủ không thể chain phản hồi
	if e:IsHasType(EFFECT_TYPE_ACTIVATE)
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_REIMU),tp,LOCATION_MZONE,0,1,nil) then
		Duel.SetChainLimit(aux.FALSE)
	end
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_REMOVED) then
		local c=e:GetHandler()
		-- Vô hiệu hóa hiệu ứng của lá bài vừa bị trục xuất
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		-- Cấm đối thủ kích hoạt bài/hiệu ứng có cùng tên gốc đến hết lượt
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e3:SetCode(EFFECT_CANNOT_ACTIVATE)
		e3:SetTargetRange(0,1)
		e3:SetValue(s.aclimit)
		e3:SetLabel(tc:GetOriginalCodeRule())
		e3:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e3,tp)
	end
end

function s.aclimit(e,re,tp)
	return re:GetHandler():IsOriginalCodeRule(e:GetLabel())
end

--------------------------------------------------------------------------------
-- 2. LOGIC THU HỒI QUÁI THÚ "GENSOKYO" ĐANG BỊ TRỤC XUẤT TỪ MỘ
--------------------------------------------------------------------------------
function s.thfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_GENSOKYO) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_REMOVED) and s.thfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_REMOVED,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end