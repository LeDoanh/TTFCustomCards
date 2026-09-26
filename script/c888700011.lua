-- Rising HERO Argent Ultimate
-- ID: 888700011
local s,id=GetID()

local SET_RISING_HERO = 0xff8
local SET_HERO		= 0x8

s.listed_series={SET_RISING_HERO, SET_HERO}

function s.initial_effect(c)
	-- Yêu cầu Dung Hợp (Fusion Procedure)
	c:EnableReviveLimit()
	-- Nguyên liệu: 1 quái Fusion "HERO" + 2 quái "Rising HERO"
	Fusion.AddProcMixN(c, true, true, s.matfilter1, 1, s.matfilter2, 2)

	-- Điều kiện Triệu hồi đặc biệt: Bắt buộc phải Dung Hợp, không thể gọi bằng cách khác
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(aux.fuslimit)
	c:RegisterEffect(e0)

	-- Hiệu ứng 1: Chọn 1 quái thú ngửa mặt trên sân -> Lá này tăng ATK bằng ATK của quái đó
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id) -- [HOPT] 1 lần mỗi lượt
	e1:SetTarget(s.atktg)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)

	-- Hiệu ứng 2 (Quick Effect): Vô hiệu hóa và phá hủy lá bài/hiệu ứng vừa kích hoạt
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+100) -- [HOPT] 1 lần mỗi lượt
	e2:SetCondition(s.negcon)
	e2:SetCost(s.negcost)
	e2:SetTarget(s.negtg)
	e2:SetOperation(s.negop)
	c:RegisterEffect(e2)
end

--------------------------------------------------------------------------------
-- FUSION MATERIAL FILTERS
--------------------------------------------------------------------------------
function s.matfilter1(c, fc, sumtype, tp)
	return c:IsSetCard(SET_HERO, fc, sumtype, tp) and c:IsType(TYPE_FUSION, fc, sumtype, tp)
end

function s.matfilter2(c, fc, sumtype, tp)
	return c:IsSetCard(SET_RISING_HERO, fc, sumtype, tp)
end

--------------------------------------------------------------------------------
-- 1. GAIN ATK LOGIC
--------------------------------------------------------------------------------
-- Hàm lọc quái thú ngửa mặt có ATK > 0
function s.atkfilter(c)
	return c:IsFaceup() and c:GetAttack() > 0
end

function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.atkfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.atkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.atkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,g,1,0,0)
end

function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() and c:IsRelateToEffect(e) and c:IsFaceup() then
		local atk=tc:GetAttack()
		if atk>0 then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(atk)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
			c:RegisterEffect(e1)
		end
	end
end

--------------------------------------------------------------------------------
-- 2. NEGATE & DESTROY LOGIC
--------------------------------------------------------------------------------
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsChainNegatable(ev)
end

function s.cfilter(c)
	return c:IsSetCard(SET_HERO) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end

function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end

function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsRelateToEffect(re) and re:GetHandler():IsDestructable() then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end

function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end