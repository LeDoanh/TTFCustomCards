-- Sanctum of the Scarlet Sky
-- ID: 90600119
local s,id=GetID()
local SET_CRIMSON = 0x1405

function s.initial_effect(c)
	-- ① Kích hoạt: Add Crimson Slifer hoặc card list Slifer từ Deck lên tay
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)

	-- ② Kháng chọn mục tiêu cho quái Level 10+
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(s.immtg)
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)

	-- Kháng hủy diệt cho quái Level 10+
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e3:SetCode(EFFECT_CANNOT_DESTROY)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetTarget(s.immtg)
	e3:SetValue(aux.indoval)
	c:RegisterEffect(e3)

	-- Chặn Slifer tự gửi vào GY ở End Phase
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_TO_GRAVE)
	e4:SetRange(LOCATION_FZONE)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetTarget(s.togravetg)
	c:RegisterEffect(e4)

	-- ③ Khi đối thủ SS ở Attack Position khi kiểm soát Divine-Beast: Đổi sang Def hoặc banish úp mặt (nếu là FIRE Divine-Beast)
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,0))
	e5:SetCategory(CATEGORY_POSITION+CATEGORY_REMOVE)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	e5:SetRange(LOCATION_FZONE)
	e5:SetCondition(s.poscon)
	e5:SetTarget(s.postg)
	e5:SetOperation(s.posop)
	c:RegisterEffect(e5)
end

function s.thfilter(c)
	return (c:IsCode(90600112) or c:ListsCode(10000000)) and c:IsAbleToHand()
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end

function s.immtg(e,c)
	return c:IsLevelAbove(10)
end

function s.togravetg(e,c)
	return c:IsCode(10000000)
end

function s.cfilter(c,tp)
	return c:IsControler(1-tp) and c:IsSummonLocation(LOCATION_EXTRA+LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
		and c:IsPosition(POS_ATTACK)
end

function s.poscon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(Card.IsRace,tp,LOCATION_MZONE,0,1,nil,RACE_DIVINEBEAST)
		and eg:IsExists(s.cfilter,1,nil,tp)
end

function s.firedivinefilter(c)
	return c:IsFaceup() and c:IsRace(RACE_DIVINEBEAST) and c:IsAttribute(ATTRIBUTE_FIRE)
end

function s.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(s.cfilter,1,nil,tp) end
	local g=eg:Filter(s.cfilter,nil,tp)
	Duel.SetTargetCard(g)
	local b_fire=Duel.IsExistingMatchingCard(s.firedivinefilter,tp,LOCATION_MZONE,0,1,nil)
	if b_fire then
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_ONFIELD)
	else
		Duel.SetOperationInfo(0,CATEGORY_POSITION,g,#g,0,POS_DEFENSE)
	end
end

function s.posop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	local b_fire=Duel.IsExistingMatchingCard(s.firedivinefilter,tp,LOCATION_MZONE,0,1,nil)
	if b_fire and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,nil) 
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local sg=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,1,nil)
		if #sg>0 then
			Duel.Remove(sg,POS_FACEDOWN,REASON_EFFECT)
		end
	else
		for tc in aux.Next(g) do
			if tc:IsFaceup() then
				Duel.ChangePosition(tc,POS_FACEUP_DEFENSE)
			end
		end
	end
end