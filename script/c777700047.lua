-- Gensokyo Eientei - Wish for the Future
-- ID: 777700047
local s,id=GetID()

local SET_GENSOKYO		 = 0xa70
local SET_GENSOKYO_EIENTEI = 0x8fc

s.listed_series={SET_GENSOKYO,SET_GENSOKYO_EIENTEI}

function s.initial_effect(c)
	-- Hiệu ứng 1A (Khi bài/hiệu ứng sắp phá hủy bài bạn điều khiển):
	-- Trục xuất 1 Link-5 "Gensokyo Eientei" bạn điều khiển đến End Phase;
	-- các lá bài bạn điều khiển khi hiệu ứng này giải quyết không thể bị phá hủy đến hết lượt
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.actcon1)
	e1:SetCost(s.actcost)
	e1:SetTarget(s.acttg)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)

	-- Hiệu ứng 1B (Khi quái thú bạn điều khiển sắp bị tiêu diệt bởi chiến đấu)
	local e1b=e1:Clone()
	e1b:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1b:SetCondition(s.actcon2)
	c:RegisterEffect(e1b)

	-- Hiệu ứng 2 (Dưới Mộ - Trừ lượt lá này được gửi xuống Mộ):
	-- Trục xuất lá này và 1 Spell khác trong Mộ -> Triệu hồi Đặc biệt 1 quái thú "Gensokyo Eientei" từ Deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(aux.exccon)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end

--------------------------------------------------------------------------------
-- 1. LOGIC CHỐNG PHÁ HỦY BẰNG CÁCH TRỤC XUẤT LINK-5 "GENSOKYO EIENTEI" ĐẾN END PHASE
--------------------------------------------------------------------------------
function s.actcon1(e,tp,eg,ep,ev,re,r,rp)
	local ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_DESTROY)
	if not ex or not (tg or tc>0) then return false end
	if tg and tg:IsExists(Card.IsControler,1,nil,tp) then return true end
	if not tg and tc>0 and Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)>0 then return true end
	return false
end

function s.actcon2(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	if not d or not a:IsRelateToBattle() or not d:IsRelateToBattle() then return false end
	if a:IsControler(tp) then
		return d:IsAttackPos() and a:GetAttack()<=d:GetAttack()
	elseif d:IsControler(tp) then
		if d:IsAttackPos() then
			return d:GetAttack()<=a:GetAttack()
		else
			return d:GetDefense()<a:GetAttack()
		end
	end
	return false
end

function s.costfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_GENSOKYO_EIENTEI) and c:IsType(TYPE_LINK) and c:GetLink()==5
		and c:IsAbleToRemoveAsCost()
end

function s.actcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local tc=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
	if tc and Duel.Remove(tc,POS_FACEUP,REASON_COST+REASON_TEMPORARY)~=0 then
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetLabelObject(tc)
		e1:SetCountLimit(1)
		e1:SetOperation(s.retop)
		Duel.RegisterEffect(e1,tp)
	end
end

function s.retop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc and tc:HasFlagEffect(id) then
		Duel.ReturnToField(tc)
	end
end

function s.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,0):Filter(function(tc) return tc~=c end,nil)
	for tc in aux.Next(g) do
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(3008)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		tc:RegisterEffect(e2)
	end
end

--------------------------------------------------------------------------------
-- 2. LOGIC TRỤC XUẤT TỪ MỘ & 1 SPELL KHÁC -> TRIỆU HỒI TỪ DECK
--------------------------------------------------------------------------------
function s.spcostfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToRemoveAsCost()
end

function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemoveAsCost()
		and Duel.IsExistingMatchingCard(s.spcostfilter,tp,LOCATION_GRAVE,0,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.spcostfilter,tp,LOCATION_GRAVE,0,1,1,c)
	g:AddCard(c)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end

function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_GENSOKYO_EIENTEI) and c:IsType(TYPE_MONSTER)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end