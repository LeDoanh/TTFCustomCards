-- Gensokyo Eientei - Fighting the Spirit
-- ID: 777700052
local s,id=GetID()

local SET_GENSOKYO		 = 0xa70
local SET_GENSOKYO_EIENTEI = 0x8fc

s.listed_series={SET_GENSOKYO,SET_GENSOKYO_EIENTEI}

function s.initial_effect(c)
	-- Hiệu ứng 1: Chỉ có thể kích hoạt vào đầu Battle Phase khi bạn điều khiển quái thú "Gensokyo Eientei".
	-- Gửi toàn bộ quái thú trên sân xuống Mộ, so sánh tổng ATK của quái thú bị gửi đi từ mỗi sân;
	-- người chơi có tổng ATK cao hơn gây sát thương cho đối phương bằng phần chênh lệch, sau đó kết thúc Battle Phase
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_BATTLE_START,TIMING_BATTLE_START)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.actcon)
	e1:SetTarget(s.acttg)
	e1:SetOperation(s.actop)
	c:RegisterEffect(e1)

	-- Hiệu ứng 2 (Dưới Mộ): Khi đối thủ tuyên bố tấn công -> Trục xuất lá bài này và 1 lá "Gensokyo" từ Mộ;
	-- kết thúc lượt của đối thủ
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.endcon)
	e2:SetCost(s.endcost)
	e2:SetOperation(s.endop)
	c:RegisterEffect(e2)
end

--------------------------------------------------------------------------------
-- 1. LOGIC GỬI TOÀN BỘ QUÁI XUỐNG MỘ -> SO SÁNH TỔNG ATK & GÂY DAMAGE -> END BATTLE PHASE
--------------------------------------------------------------------------------
function s.actcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()==PHASE_BATTLE_START
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_GENSOKYO_EIENTEI),tp,LOCATION_MZONE,0,1,nil)
end

function s.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,LOCATION_MZONE)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,#g,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,0)
end

function s.actop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,LOCATION_MZONE)
	if #g>0 and Duel.SendtoGrave(g,REASON_EFFECT)>0 then
		local og=Duel.GetOperatedGroup():Filter(Card.IsLocation,nil,LOCATION_GRAVE)
		local atk_tp=0
		local atk_opp=0
		for tc in aux.Next(og) do
			local atk=tc:IsPreviousPosition(POS_FACEUP) and math.max(0,tc:GetPreviousAttackOnField()) or math.max(0,tc:GetAttack())
			if tc:GetPreviousControler()==tp then
				atk_tp=atk_tp+atk
			elseif tc:GetPreviousControler()==1-tp then
				atk_opp=atk_opp+atk
			end
		end
		if atk_tp>atk_opp then
			Duel.Damage(1-tp,atk_tp-atk_opp,REASON_EFFECT)
		elseif atk_opp>atk_tp then
			Duel.Damage(tp,atk_opp-atk_tp,REASON_EFFECT)
		end
	end
	if Duel.IsBattlePhase() then
		Duel.BreakEffect()
		Duel.SkipPhase(Duel.GetTurnPlayer(),PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE_STEP,1)
	end
end

--------------------------------------------------------------------------------
-- 2. LOGIC DƯỚI MỘ: KHI ĐỐI THỦ TUYÊN BỐ TẤN CÔNG -> KẾT THÚC LƯỢT ĐỐI THỦ
--------------------------------------------------------------------------------
function s.endcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttacker():IsControler(1-tp)
end

function s.cfilter(c)
	return c:IsSetCard(SET_GENSOKYO) and c:IsAbleToRemoveAsCost()
end

function s.endcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemoveAsCost()
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,1,1,c)
	g:AddCard(c)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end

function s.endop(e,tp,eg,ep,ev,re,r,rp)
	Duel.SkipPhase(1-tp,PHASE_DRAW,RESET_PHASE+PHASE_END,1)
	Duel.SkipPhase(1-tp,PHASE_STANDBY,RESET_PHASE+PHASE_END,1)
	Duel.SkipPhase(1-tp,PHASE_MAIN1,RESET_PHASE+PHASE_END,1)
	Duel.SkipPhase(1-tp,PHASE_BATTLE,RESET_PHASE+PHASE_END,1)
	Duel.SkipPhase(1-tp,PHASE_MAIN2,RESET_PHASE+PHASE_END,1)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BP)
	e1:SetTargetRange(0,1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end