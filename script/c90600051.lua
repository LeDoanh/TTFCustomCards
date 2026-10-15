-- Sky Striker Ace - Harbinger of Salvation
-- ID: 90600051
local s,id=GetID()
function s.initial_effect(c)
	-- Nguyên liệu Link: 2+ quái thú "Sky Striker"
	c:EnableReviveLimit()
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_SKY_STRIKER),2)

	-- Bắt buộc phải Link Summon trước tiên
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(aux.lnklimit)
	c:RegisterEffect(e1)

	-- Hiệu ứng 1: Spells/Traps đang Úp bạn điều khiển không thể bị chỉ định (target) hoặc phá hủy bởi hiệu ứng card của đối thủ
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_SZONE,0)
	e2:SetTarget(s.indtg)
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetValue(aux.indoval)
	c:RegisterEffect(e3)

	-- Hiệu ứng 2: Khi đối thủ kích hoạt card/effect (Quick Effect): Trộn 1 "Sky Striker" Spell từ GY vào Deck -> Vô hiệu hóa hiệu ứng đó, sau đó có thể Úp 1 "Sky Striker" Spell từ Deck/GY
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_DISABLE+CATEGORY_TODECK+CATEGORY_LEAVE_GRAVE)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_CHAINING)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id)
	e4:SetCondition(s.discon)
	e4:SetCost(s.discost)
	e4:SetTarget(s.distg)
	e4:SetOperation(s.disop)
	c:RegisterEffect(e4)
end

s.listed_series={SET_SKY_STRIKER}

--------------------------------------------------------------------------------
-- HIỆU ỨNG 1: BẢO VỆ PHÉP/BẪY ĐANG ÚP (SET SPELL/TRAP)
--------------------------------------------------------------------------------
function s.indtg(e,c)
	return c:IsFacedown()
end

--------------------------------------------------------------------------------
-- HIỆU ỨNG 2: VÔ HIỆU HÓA HIỆU ỨNG VÀ ÚP SPELL TỪ DECK/GY
--------------------------------------------------------------------------------
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp and Duel.IsChainDisablable(ev)
end

function s.tdfilter(c)
	return c:IsSetCard(SET_SKY_STRIKER) and c:IsSpell() and c:IsAbleToDeck()
end

function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
end

function s.setfilter(c)
	return c:IsSetCard(SET_SKY_STRIKER) and c:IsSpell() and c:IsSSetable()
end

function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,LOCATION_GRAVE)
end

function s.disop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateEffect(ev) then
		local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.setfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,nil)
		if #g>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
			local sg=g:Select(tp,1,1,nil)
			if #sg>0 then
				Duel.SSet(tp,sg)
			end
		end
	end
end