-- Gensokyo Eientei - Hunting of the Night
-- ID: 777700050
local s,id=GetID()

local SET_GENSOKYO		 = 0xa70
local SET_GENSOKYO_EIENTEI = 0x8fc

s.listed_series={SET_GENSOKYO,SET_GENSOKYO_EIENTEI}

function s.initial_effect(c)
	-- Hiệu ứng 1: Chỉ có thể kích hoạt khi bạn điều khiển 2 quái thú Link-5 đang Co-Linked với nhau.
	-- Trong phần còn lại của lượt này, mỗi khi đối thủ kích hoạt hiệu ứng quái thú,
	-- toàn bộ quái thú đối thủ đang điều khiển mất 500 ATK/DEF, sau đó phá hủy toàn bộ quái thú đối thủ có 0 ATK và DEF
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_STANDBY_PHASE+TIMING_MAIN_END)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.actcon)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)

	-- Hiệu ứng 2 (Quick Effect - Dưới Mộ): Khi 1 lá bài hoặc hiệu ứng được kích hoạt chọn mục tiêu
	-- 1 quái thú "Gensokyo Eientei" bạn điều khiển -> Trục xuất lá bài này; vô hiệu hóa hiệu ứng đó
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.negcon)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.negtg)
	e2:SetOperation(s.negop)
	c:RegisterEffect(e2)
end

--------------------------------------------------------------------------------
-- 1. LOGIC ĐIỀU KIỆN 2 QUÁI LINK-5 CO-LINKED & TRỪ 500 ATK/DEF + PHÁ HỦY 0 ATK/DEF
--------------------------------------------------------------------------------
function s.lk5filter(c)
	return c:IsFaceup() and c:IsType(TYPE_LINK) and c:GetLink()==5
end

function s.actcon(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.lk5filter,tp,LOCATION_MZONE,0,nil)
	if #g<2 then return false end
	for c1 in aux.Next(g) do
		local mg=c1:GetMutualLinkedGroup()
		if mg:IsExists(function(c2) return c2:IsControler(tp) and g:IsContains(c2) end,1,nil) then
			return true
		end
	end
	return false
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- Theo dõi hiệu ứng quái thú đối thủ kích hoạt và áp dụng ngay sau khi mắt xích đó giải quyết
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAIN_SOLVED)
	e1:SetCondition(s.debuffcon)
	e1:SetOperation(s.debuffop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end

function s.debuffcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsActiveType(TYPE_MONSTER)
		and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil)
end

function s.desfilter(c)
	return c:IsFaceup() and c:IsAttack(0) and c:IsDefense(0)
end

function s.debuffop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	if #g==0 then return end
	Duel.Hint(HINT_CARD,0,id)
	local c=e:GetHandler()
	for tc in aux.Next(g) do
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		tc:RegisterEffect(e2)
	end
	Duel.AdjustAll()
	local dg=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_MZONE,nil)
	if #dg>0 then
		Duel.Destroy(dg,REASON_EFFECT)
	end
end

--------------------------------------------------------------------------------
-- 2. LOGIC VÔ HIỆU HÓA HIỆU ỨNG CHỌN MỤC TIÊU QUÁI "GENSOKYO EIENTEI"
--------------------------------------------------------------------------------
function s.tgfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:IsSetCard(SET_GENSOKYO_EIENTEI)
end

function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) or not Duel.IsChainDisablable(ev) then return false end
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return g and g:IsExists(s.tgfilter,1,nil,tp)
end

function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end

function s.negop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateEffect(ev)
end
