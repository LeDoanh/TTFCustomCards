-- Sky Striker Mobilize - Dual Clash
-- ID: 90600029
local s,id=GetID()
function s.initial_effect(c)
	-- Hiệu ứng 1: Thêm 1 quái thú "Sky Striker" từ Deck lên tay, nếu có >=3 Phép trong Mộ thì có thể Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)

	-- Hiệu ứng 2: Loại bỏ từ Mộ khi quái thú "Sky Striker" chiến đấu để phá hủy 1 lá bài của đối thủ
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLED)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(aux.bfgcost)
	e2:SetCondition(s.descon)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end

s.listed_series={SET_SKY_STRIKER}

--------------------------------------------------------------------------------
-- HIỆU ỨNG 1: SEARCH / SPECIAL SUMMON TỪ DECK
--------------------------------------------------------------------------------
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,LOCATION_MMZONE,0)==0
		or Duel.IsExistingMatchingCard(function(c) return c:IsFaceup() and (c:IsCode(90600061) or c:IsCode(90600003) or c:IsCode(90600024)) end,tp,LOCATION_FZONE+LOCATION_MZONE,0,1,nil)
end

function s.filter(c,e,tp)
	return c:IsSetCard(SET_SKY_STRIKER) and c:IsMonster() 
		and (c:IsAbleToHand() or (Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		local b1=tc:IsAbleToHand()
		local b2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
			and tc:IsCanBeSpecialSummoned(e,0,tp,false,false) 
			and Duel.GetMatchingGroupCount(Card.IsSpell,tp,LOCATION_GRAVE,0,nil)>=3
			
		local op=0
		if b1 and b2 then
			op=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))
		elseif b1 then
			op=0
		elseif b2 then
			op=1
		else
			return
		end
		
		if op==0 then
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,tc)
		else
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end

--------------------------------------------------------------------------------
-- HIỆU ỨNG 2: BFG KHI BATTLED ĐỂ DESTROY CARD
--------------------------------------------------------------------------------
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	if not a then return false end
	return (a:IsControler(tp) and a:IsSetCard(SET_SKY_STRIKER))
		or (d and d:IsControler(tp) and d:IsSetCard(SET_SKY_STRIKER))
end

function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end