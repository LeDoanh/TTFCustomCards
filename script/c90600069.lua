-- Sky Striker Mobilize - Network Sync
-- ID: 90600069
local s,id=GetID()
function s.initial_effect(c)
	-- Hiệu ứng 1: Gửi 1 lá "Sky Striker" từ trên tay hoặc Deck xuống GY -> Target 1 lá "Sky Striker" trong GY; lấy lên tay
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)

	-- Hiệu ứng 2: Cho phép kích hoạt lá bài này từ trên tay trong lượt của đối thủ nếu bạn điều khiển quái thú "Sky Striker Ace" Link Monster
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_QP_ACT_IN_NTPHAND)
	e2:SetCondition(s.handcon)
	c:RegisterEffect(e2)
end

s.listed_series={SET_SKY_STRIKER,SET_SKY_STRIKER_ACE}

--------------------------------------------------------------------------------
-- HIỆU ỨNG KÍCH HOẠT TỪ TAY TRONG LƯỢT ĐỐI THỦ
--------------------------------------------------------------------------------
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_SKY_STRIKER_ACE) and c:IsType(TYPE_LINK)
end

function s.handcon(e)
	return Duel.IsExistingMatchingCard(s.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end

--------------------------------------------------------------------------------
-- TARGET & OPERATION
--------------------------------------------------------------------------------
function s.tgfilter(c,e)
	return c:IsSetCard(SET_SKY_STRIKER) and c:IsAbleToGrave() and c~=e:GetHandler()
end

function s.thfilter(c)
	return c:IsSetCard(SET_SKY_STRIKER) and c:IsAbleToHand()
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.thfilter(chkc) end
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e)
			and Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE,0,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
	
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local tg=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,tg,1,0,0)
	-- Lưu lại lá bài được chọn gửi xuống GY vào hiệu ứng để dùng ở Operation
	e:SetLabelObject(g:GetFirst())
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc and Duel.SendtoGrave(tc,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_GRAVE) then
		local sc=Duel.GetFirstTarget()
		if sc and sc:IsRelateToEffect(e) then
			Duel.BreakEffect()
			Duel.SendtoHand(sc,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,sc)
		end
	end
end