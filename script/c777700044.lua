-- Gensokyo Eientei - Reisen the Doomer
-- ID: 777700044
local s,id=GetID()

local SET_GENSOKYO		 = 0xa70
local SET_GENSOKYO_EIENTEI = 0x8fc

s.listed_series={SET_GENSOKYO,SET_GENSOKYO_EIENTEI}

function s.initial_effect(c)
	-- Quy tắc Triệu hồi Liên kết: 3 quái thú, bao gồm ít nhất 1 quái thú "Gensokyo Eientei"
	c:EnableReviveLimit()
	Link.AddProcedure(c,nil,3,3,s.lcheck)

	-- Hiệu ứng 1: Khi được Triệu hồi Liên kết -> Chọn 1 lá bài ngửa mặt đối thủ điều khiển;
	-- trục xuất nó cho đến hết End Phase lượt tiếp theo của đối thủ
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.rmcon1)
	e1:SetTarget(s.rmtg1)
	e1:SetOperation(s.rmop1)
	c:RegisterEffect(e1)

	-- Hiệu ứng 2 (Quick Effect): Khi đối thủ kích hoạt lá bài hoặc hiệu ứng trên tay hoặc trong Mộ
	-- -> Trục xuất 1 lá "Gensokyo Eientei" từ Mộ của bạn; vô hiệu hóa hiệu ứng đó
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.negcon)
	e2:SetCost(s.negcost)
	e2:SetTarget(s.negtg)
	e2:SetOperation(s.negop)
	c:RegisterEffect(e2)

	-- Hiệu ứng 3: Khi lá bài này đang ở trạng thái Co-Linked, đối thủ không thể kích hoạt Spell Card
	-- ngay trong lượt chúng được úp (Set), trừ khi gửi 1 lá trên tay xuống Mộ để kích hoạt
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_ACTIVATE_COST)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,1)
	e3:SetCondition(s.actcon)
	e3:SetTarget(s.acttg)
	e3:SetCost(s.actcost)
	e3:SetOperation(s.actop)
	c:RegisterEffect(e3)

	-- Hiệu ứng 4: Nếu lá bài đã được Link Summon này bị gửi xuống Mộ
	-- -> Chọn 1 lá bài trong Mộ đối thủ; trục xuất lá đó
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_REMOVE)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCountLimit(1,{id,2})
	e4:SetCondition(s.rmcon2)
	e4:SetTarget(s.rmtg2)
	e4:SetOperation(s.rmop2)
	c:RegisterEffect(e4)
end

--------------------------------------------------------------------------------
-- 1. BỘ LỌC NGUYÊN LIỆU LINK (PHẢI CÓ ÍT NHẤT 1 QUÁI "GENSOKYO EIENTEI")
--------------------------------------------------------------------------------
function s.lcheck(g,lc,sumtype,tp)
	return g:IsExists(Card.IsSetCard,1,nil,SET_GENSOKYO_EIENTEI,lc,sumtype,tp)
end

--------------------------------------------------------------------------------
-- 2. LOGIC TRỤC XUẤT TẠM THỜI ĐẾN END PHASE LƯỢT TIẾP THEO CỦA ĐỐI THỦ
--------------------------------------------------------------------------------
function s.rmcon1(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end

function s.rmfilter1(c)
	return c:IsFaceup() and c:IsAbleToRemove()
end

function s.rmtg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and s.rmfilter1(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.rmfilter1,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,s.rmfilter1,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end

function s.rmop1(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT+REASON_TEMPORARY)>0
		and tc:IsLocation(LOCATION_REMOVED) then
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
		local ct=(Duel.GetTurnPlayer()==1-tp) and 2 or 1
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetLabel(ct)
		e1:SetLabelObject(tc)
		e1:SetCondition(s.retcon)
		e1:SetOperation(s.retop)
		Duel.RegisterEffect(e1,tp)
	end
end

function s.retcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if not tc or not tc:HasFlagEffect(id) or not tc:IsLocation(LOCATION_REMOVED) then
		e:Reset()
		return false
	end
	return Duel.GetTurnPlayer()==1-tp
end

function s.retop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()-1
	if ct>0 then
		e:SetLabel(ct)
	else
		local tc=e:GetLabelObject()
		if tc and tc:HasFlagEffect(id) then
			Duel.ReturnToField(tc)
		end
		e:Reset()
	end
end

--------------------------------------------------------------------------------
-- 3. LOGIC QUICK EFFECT VÔ HIỆU HÓA KÍCH HOẠT TỪ TAY / MỘ ĐỐI THỦ
--------------------------------------------------------------------------------
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	if ep~=1-tp or not Duel.IsChainDisablable(ev) then return false end
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	return (loc&(LOCATION_HAND+LOCATION_GRAVE))~=0
end

function s.costfilter(c)
	return c:IsSetCard(SET_GENSOKYO_EIENTEI) and c:IsAbleToRemoveAsCost()
end

function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end

function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end

function s.negop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateEffect(ev)
end

--------------------------------------------------------------------------------
-- 4. LOGIC ÉP TRẢ COST KHI KÍCH HOẠT SPELL ĐƯỢC SET TRONG LƯỢT KHI CO-LINKED
--------------------------------------------------------------------------------
function s.actcon(e)
	return e:GetHandler():GetMutualLinkedGroupCount()>0
end

function s.acttg(e,te,tp)
	local tc=te:GetHandler()
	return te:IsHasType(EFFECT_TYPE_ACTIVATE) and te:IsActiveType(TYPE_SPELL)
		and tc:IsFacedown() and tc:IsStatus(STATUS_SET_TURN)
end

function s.actcost(e,te,tp)
	return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,nil)
end

function s.actop(e,te,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end

--------------------------------------------------------------------------------
-- 5. LOGIC TRỤC XUẤT 1 LÁ TRONG MỘ ĐỐI THỦ KHI BỊ GỬI XUỐNG MỘ
--------------------------------------------------------------------------------
function s.rmcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end

function s.rmtg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_GRAVE) and chkc:IsAbleToRemove() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end

function s.rmop2(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
