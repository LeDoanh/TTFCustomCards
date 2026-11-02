-- Sky Striker Special Maneuver – Supreme Override
-- ID: 90600068
local s,id=GetID()
function s.initial_effect(c)
	-- Kích hoạt lá bài Spell (Chỉ được kích hoạt 1 lần mỗi lượt)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

s.listed_series={SET_SKY_STRIKER,SET_SKY_STRIKER_ACE}

--------------------------------------------------------------------------------
-- ĐIỀU KIỆN KÍCH HOẠT: Bạn phải điều khiển 1 quái thú "Sky Striker Ace"
--------------------------------------------------------------------------------
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_SKY_STRIKER_ACE)
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end

--------------------------------------------------------------------------------
-- TARGET & OPERATION
--------------------------------------------------------------------------------
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() and chkc:IsControlerCanBeChanged() end
	if chk==0 then return Duel.IsExistingTarget(function(c) return c:IsFaceup() and c:IsControlerCanBeChanged() end,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	local g=Duel.SelectTarget(tp,function(c) return c:IsFaceup() and c:IsControlerCanBeChanged() end,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- Kiểm tra xem trong GY có từ 6 Spell trở lên hay không
		local has_6_spells = Duel.GetMatchingGroupCount(Card.IsSpell,tp,LOCATION_GRAVE,0,nil)>=6
		
		if has_6_spells then
			-- Cướp quyền kiểm soát vĩnh viễn và trở thành quái thú "Sky Striker"
			if Duel.GetControl(tc,tp) then
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_ADD_SETCODE)
				e1:SetValue(SET_SKY_STRIKER)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e1)
			end
		else
			-- Cướp quyền kiểm soát cho đến End Phase
			Duel.GetControl(tc,tp,PHASE_END,1)
		end
	end
end