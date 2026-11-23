-- Gensokyo Magic Sign Master Spark
-- ID: 777700005
local s,id=GetID()

local SET_GENSOKYO = 0xa70
local CARD_MARISA  = 777700002 -- Gensokyo Ordinary Magician - Marisa Kirisame

s.listed_series={SET_GENSOKYO}
s.listed_names={id,CARD_MARISA}

function s.initial_effect(c)
	-- Hiệu ứng 1: Phá hủy toàn bộ bài ở cột của mục tiêu và 2 cột liền kề + Bảo hộ chống hiệu ứng Phép nếu có Marisa
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E+TIMING_END_PHASE)
	e1:SetCountLimit(1,id) -- Dùng chung HOPT với Hiệu ứng 2 (chỉ được xài 1 trong 2 hiệu ứng mỗi lượt)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)

	-- Hiệu ứng 2: Trục xuất lá này từ Mộ + 1 Marisa -> Thu hồi 1 Spell/Trap "Gensokyo" từ Mộ/Trục xuất, sau đó mill 1 lá
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_DECKDES)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id) -- Dùng chung HOPT với Hiệu ứng 1
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end

--------------------------------------------------------------------------------
-- 1. LOGIC PHÁ HỦY THEO CỘT + BẢO HỘ CHỐNG SPELL
--------------------------------------------------------------------------------
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_GENSOKYO),tp,LOCATION_MZONE,0,1,nil)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() end
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local tc=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil):GetFirst()
	-- Lấy toàn bộ bài trong cột của mục tiêu và 2 cột kế bên (trừ chính lá Phép đang kích hoạt này)
	local g=tc:GetColumnGroup(1,1)
	g:AddCard(tc)
	g:RemoveCard(e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		local g=tc:GetColumnGroup(1,1)
		g:AddCard(tc)
		g:RemoveCard(e:GetHandler())
		if #g>0 then
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
	-- Nếu điều khiển "Gensokyo Ordinary Magician - Marisa Kirisame", quái "Gensokyo" không bị hủy bởi hiệu ứng Spell lượt này
	if Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_MARISA),tp,LOCATION_MZONE,0,1,nil) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e1:SetTargetRange(LOCATION_MZONE,0)
		e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_GENSOKYO))
		e1:SetValue(s.indval)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end

function s.indval(e,re,tp)
	return re:IsActiveType(TYPE_SPELL)
end

--------------------------------------------------------------------------------
-- 2. LOGIC THU HỒI SPELL/TRAP TỪ MỘ/TRỤC XUẤT + MILL 1 LÁ
--------------------------------------------------------------------------------
function s.costfilter(c,tp)
	return c:IsCode(CARD_MARISA) and c:IsAbleToRemoveAsCost()
		and (not c:IsLocation(LOCATION_DECK) or Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>1)
end

function s.thfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_GENSOKYO) and c:IsType(TYPE_SPELL+TYPE_TRAP)
		and not c:IsCode(id) and c:IsAbleToHand()
end

function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemoveAsCost()
		and Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_DECK+LOCATION_GRAVE,0,1,c,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_DECK+LOCATION_GRAVE,0,1,1,c,tp)
	g:AddCard(c)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,e:GetHandler())
		and Duel.IsPlayerCanDiscardDeck(tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,1)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 and g:GetFirst():IsLocation(LOCATION_HAND) then
		Duel.ConfirmCards(1-tp,g)
		Duel.BreakEffect()
		Duel.DiscardDeck(tp,1,REASON_EFFECT)
	end
end
