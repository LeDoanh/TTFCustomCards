-- Sky Striker Special Maneuver - Plasma Cannon
-- ID: 90600058
local s,id=GetID()
function s.initial_effect(c)
	-- Kích hoạt lá bài Spell (Chỉ được kích hoạt 1 lần mỗi lượt)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_DESTROY+CATEGORY_DAMAGE)
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

s.listed_series={SET_SKY_STRIKER}

--------------------------------------------------------------------------------
-- ĐIỀU KIỆN KÍCH HOẠT: Sân không có quái ở MMZ (hoặc có hiệu ứng Bypass từ 90600003)
--------------------------------------------------------------------------------
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,LOCATION_MMZONE,0)==0 
		or Duel.IsExistingMatchingCard(function(c) return c:IsFaceup() and (c:IsCode(90600059) or c:IsCode(90600003) or c:IsCode(90600024)) end,tp,LOCATION_MZONE,0,1,nil)
end

--------------------------------------------------------------------------------
-- TARGET & OPERATION
--------------------------------------------------------------------------------
function s.disfilter(c)
	return c:IsFaceup() and not c:IsDisabled()
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.disfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.disfilter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
	local g=Duel.SelectTarget(tp,s.disfilter,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
	if Duel.GetMatchingGroupCount(Card.IsSpell,tp,LOCATION_GRAVE,0,nil)>=3 then
		Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
		Duel.SetPossibleOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
	end
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) and not tc:IsDisabled() then
		-- Vô hiệu hóa hiệu ứng của quái thú đối thủ đến hết lượt
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

		-- Nếu có từ 3 Spell trở lên trong GY: Phá hủy quái thú đó và gây sát thương bằng nửa ATK gốc
		if Duel.GetMatchingGroupCount(Card.IsSpell,tp,LOCATION_GRAVE,0,nil)>=3 then
			local atk=tc:GetBaseAttack()
			if atk<0 then atk=0 end
			if Duel.Destroy(tc,REASON_EFFECT)>0 and atk>0 then
				Duel.BreakEffect()
				Duel.Damage(1-tp,math.floor(atk/2),REASON_EFFECT)
			end
		end
	end
end