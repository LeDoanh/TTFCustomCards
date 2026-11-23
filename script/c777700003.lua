-- Gensokyo Incident - Great Hakurei Barrier
-- ID: 777700003
local s,id=GetID()

local SET_GENSOKYO   = 0xa70
local COUNTER_BLOODY = 0x1a70 -- Hỗ trợ chứa Bloody Counter nếu copy Scarlet Devil Mansion

s.listed_series={SET_GENSOKYO}
s.listed_names={id}

function s.initial_effect(c)
	c:EnableCounterPermit(COUNTER_BLOODY)

	-- Hiệu ứng 1: Kích hoạt bài -> Có thể tìm 1 quái "Gensokyo" từ Deck lên tay, sau đó bỏ 1 lá (HOPT kích hoạt lá bài)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)

	-- Hiệu ứng 2: Bảo vệ khỏi bị phá hủy bằng cách lộ 1 Field Spell trên tay (không được lộ trùng tên trong lượt)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetTarget(s.reptg)
	e2:SetOperation(s.repop)
	c:RegisterEffect(e2)

	-- Hiệu ứng 3 (Soft OPT): Lộ và trục xuất úp 1 Field Spell "Gensokyo" khác tên từ Deck -> Sao chép tên & hiệu ứng đến hết lượt
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1)
	e3:SetCost(s.cpcost)
	e3:SetOperation(s.cpop)
	c:RegisterEffect(e3)

	-- Hiệu ứng 4: Toàn bộ quái thú "Gensokyo" bạn điều khiển tăng 300 ATK/DEF
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetRange(LOCATION_FZONE)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_GENSOKYO))
	e4:SetValue(300)
	c:RegisterEffect(e4)

	local e5=e4:Clone()
	e5:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e5)
end

--------------------------------------------------------------------------------
-- 1. LOGIC KÍCH HOẠT & SEARCH + DISCARD
--------------------------------------------------------------------------------
function s.thfilter(c)
	return c:IsSetCard(SET_GENSOKYO) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		if #sg>0 and Duel.SendtoHand(sg,nil,REASON_EFFECT)>0 then
			Duel.ConfirmCards(1-tp,sg)
			Duel.ShuffleHand(tp)
			Duel.BreakEffect()
			Duel.DiscardHand(tp,aux.TRUE,1,1,REASON_EFFECT+REASON_DISCARD)
		end
	end
end

--------------------------------------------------------------------------------
-- 2. LOGIC CHỐNG PHÁ HỦY (DESTRUCTION REPLACEMENT)
--------------------------------------------------------------------------------
function s.repfilter(c,tp)
	if not c:IsType(TYPE_FIELD) or c:IsPublic() then return false end
	for _,code in ipairs({Duel.GetFlagEffectLabel(tp,id)}) do
		if c:IsCode(code) then return false end
	end
	return true
end

function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsReason(REASON_REPLACE)
		and Duel.IsExistingMatchingCard(s.repfilter,tp,LOCATION_HAND,0,1,nil,tp) end
	if Duel.SelectEffectYesNo(tp,c,aux.Stringid(id,2)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
		local tc=Duel.SelectMatchingCard(tp,s.repfilter,tp,LOCATION_HAND,0,1,1,nil,tp):GetFirst()
		e:SetLabelObject(tc)
		return true
	else
		return false
	end
end

function s.repop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if not tc then return end
	Duel.ConfirmCards(1-tp,tc)
	Duel.ShuffleHand(tp)
	for _,code in ipairs({tc:GetCode()}) do
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1,code)
	end
end

--------------------------------------------------------------------------------
-- 3. LOGIC SAO CHÉP TÊN & HIỆU ỨNG FIELD SPELL
--------------------------------------------------------------------------------
function s.cpfilter(c)
	return c:IsSetCard(SET_GENSOKYO) and c:IsType(TYPE_FIELD) and not c:IsCode(id)
		and c:IsAbleToRemoveAsCost(POS_FACEDOWN)
end

function s.cpcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cpfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local tc=Duel.SelectMatchingCard(tp,s.cpfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	Duel.ConfirmCards(1-tp,tc)
	e:SetLabel(tc:GetOriginalCodeRule())
	Duel.Remove(tc,POS_FACEDOWN,REASON_COST)
end

function s.cpop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local code=e:GetLabel()
	if c:IsRelateToEffect(e) and c:IsFaceup() and code then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetValue(code)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
		-- Copy hiệu ứng và tự động xóa bỏ hiệu ứng EFFECT_TYPE_ACTIVATE của lá Field gốc
		local cid=c:CopyEffect(code,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_ADJUST)
		e2:SetRange(LOCATION_FZONE)
		e2:SetLabel(cid)
		e2:SetOperation(s.rmactop)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e2)
	end
end

function s.rmactop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local effs={c:GetCardEffect()}
	for _,eff in ipairs(effs) do
		if eff:IsHasType(EFFECT_TYPE_ACTIVATE) and eff:GetHandler()==c then
			eff:Reset()
		end
	end
	e:Reset()
end