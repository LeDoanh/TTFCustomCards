-- Gensokyo Scarlet - Crimson Spirit
-- ID: 777700023
local s,id=GetID()

local SET_GENSOKYO		 = 0xa70
local SET_GENSOKYO_SCARLET = 0xd7c

s.listed_series={SET_GENSOKYO,SET_GENSOKYO_SCARLET}

function s.initial_effect(c)
	-- Hiệu ứng 1: Counter Trap trả 800 LP -> Vô hiệu hóa kích hoạt, phá hủy lá đó,
	-- sau đó trả 1 Fusion Monster bạn điều khiển hoặc dưới Mộ về Extra Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY+CATEGORY_TOEXTRA)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id) -- Dùng chung HOPT với Hiệu ứng 2 (chỉ được xài 1 trong 2 hiệu ứng mỗi lượt)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)

	-- Hiệu ứng 2 (Dưới Mộ): Trục xuất lá này -> Đến hết lượt, các quái Dung hợp "Gensokyo Scarlet" bạn điều khiển nhận hiệu ứng nhân đôi ATK/DEF
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_QUICK_O) -- Hiệu ứng dưới Mộ của Trap mặc định là Spell Speed 2
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END+TIMING_BATTLE_START)
	e2:SetCountLimit(1,id) -- Dùng chung HOPT với Hiệu ứng 1
	e2:SetCost(aux.bfgcost)
	e2:SetOperation(s.grantop)
	c:RegisterEffect(e2)
end

--------------------------------------------------------------------------------
-- 1. LOGIC COUNTER TRAP: VÔ HIỆU HÓA, PHÁ HỦY & TRẢ FUSION MONSTER VỀ EXTRA DECK
--------------------------------------------------------------------------------
function s.is_scarlet_cl(cl)
	local prev_re=Duel.GetChainInfo(cl,CHAININFO_TRIGGERING_EFFECT)
	if not prev_re then return false end
	if prev_re:GetHandler():IsSetCard(SET_GENSOKYO_SCARLET) then return true end
	local setcodes={Duel.GetChainInfo(cl,CHAININFO_TRIGGERING_SETCODES)}
	for _,sc in ipairs(setcodes) do
		if (sc&0xfff)==SET_GENSOKYO_SCARLET or sc==SET_GENSOKYO_SCARLET then return true end
	end
	return false
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp and ev>1 and Duel.IsChainNegatable(ev) and s.is_scarlet_cl(ev-1)
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,800) end
	Duel.PayLPCost(tp,800)
end

function s.tdfilter(c)
	return c:IsType(TYPE_FUSION) and c:IsAbleToExtra()
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,nil,1,tp,LOCATION_MZONE+LOCATION_GRAVE)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) and Duel.Destroy(eg,REASON_EFFECT)>0 then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.tdfilter),tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil)
		if #g>0 then
			Duel.HintSelection(g)
			Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	end
end

--------------------------------------------------------------------------------
-- 2. LOGIC CẤP HIỆU ỨNG NHÂN ĐÔI ATK/DEF CHO QUÁI FUSION "GENSOKYO SCARLET"
--------------------------------------------------------------------------------
function s.grantop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- Hiệu ứng Quick Effect được cấp cho từng quái Fusion "Gensokyo Scarlet"
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(TIMING_DAMAGE_STEP,TIMING_DAMAGE_STEP+TIMINGS_CHECK_MONSTER)
	e1:SetCondition(aux.StatChangeDamageStepCondition)
	e1:SetCost(s.atkcost)
	e1:SetOperation(s.atkop)

	-- Áp dụng liên tục cho tất cả quái Fusion "Gensokyo Scarlet" bạn điều khiển đến hết lượt
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.eftg)
	e2:SetLabelObject(e1)
	e2:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e2,tp)
end

function s.eftg(e,c)
	return c:IsFaceup() and c:IsSetCard(SET_GENSOKYO_SCARLET) and c:IsType(TYPE_FUSION)
end

function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,800) end
	Duel.PayLPCost(tp,800)
end

function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(c:GetAttack()*2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e2:SetValue(c:GetDefense()*2)
		c:RegisterEffect(e2)
	end
end