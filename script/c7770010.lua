-- Purrfect Trickster - Ghostly Mischief
local s,id=GetID()
local SET_PURRFECT=0x777
function s.initial_effect(c)
	-- Xyz Summon
	Xyz.AddProcedure(c,nil,2,2)
	c:EnableReviveLimit()

	-- Cannot be material
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	c:RegisterEffect(e3)
	local e4=e1:Clone()
	e4:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	c:RegisterEffect(e4)

	-- Detach 1 to bounce 1 card
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,0))
	e5:SetCategory(CATEGORY_TOHAND)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1,id)
	e5:SetCost(s.bcost)
	e5:SetTarget(s.btg)
	e5:SetOperation(s.bop)
	c:RegisterEffect(e5)

	-- While controlled by opponent: when monster effect activated, mill 1 or banish 1 face-down from GY
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e6:SetCode(EVENT_CHAIN_SOLVED)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCondition(s.milcon)
	e6:SetOperation(s.milop)
	c:RegisterEffect(e6)

	-- End Phase forced detach
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(id,1))
	e7:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e7:SetCode(EVENT_PHASE+PHASE_END)
	e7:SetRange(LOCATION_MZONE)
	e7:SetCountLimit(1)
	e7:SetCondition(s.epcon)
	e7:SetOperation(s.epop)
	c:RegisterEffect(e7)
end
s.listed_series={SET_PURRFECT}

function s.bcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.btg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsAbleToHand() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function s.bop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end

function s.milcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetControler()~=c:GetOwner() and rp==c:GetControler() and re:IsActiveType(TYPE_MONSTER)
end
function s.milop(e,tp,eg,ep,ev,re,r,rp)
	local p=e:GetHandler():GetControler()
	local b1=Duel.IsPlayerCanDiscardDeck(p,1)
	local b2=Duel.IsExistingMatchingCard(Card.IsAbleToRemove,p,LOCATION_GRAVE,0,1,nil,p,POS_FACEDOWN)
	if not (b1 or b2) then return end
	local op=0
	if b1 and b2 then
		op=Duel.SelectOption(p,aux.Stringid(id,2),aux.Stringid(id,3))
	elseif b1 then
		op=0
	else
		op=1
	end
	if op==0 then
		Duel.DiscardDeck(p,1,REASON_EFFECT)
	else
		Duel.Hint(HINT_SELECTMSG,p,HINTMSG_REMOVE)
		local g=Duel.SelectMatchingCard(p,Card.IsAbleToRemove,p,LOCATION_GRAVE,0,1,1,nil,p,POS_FACEDOWN)
		if #g>0 then
			Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)
		end
	end
end

function s.epcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return Duel.GetTurnPlayer()==c:GetControler() and c:GetTurnID()~=Duel.GetTurnCount()
end
function s.epop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	if c:GetOverlayCount()>0 then
		c:RemoveOverlayCard(c:GetControler(),1,1,REASON_EFFECT)
	else
		Duel.Destroy(c,REASON_EFFECT)
	end
end
