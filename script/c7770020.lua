-- Purrfect Gift - Tempting Apple
local s,id=GetID()
local SET_PURRFECT=0x777
function s.initial_effect(c)
	-- Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)

	-- Lock monster effect if ATK higher than opponent-controlled Purrfect Xyz
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,1)
	e2:SetCondition(s.lockcon)
	e2:SetValue(s.locklimit)
	c:RegisterEffect(e2)

	-- Detach damage & gain LP
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_DETACH_MATERIAL)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(s.damcon)
	e3:SetOperation(s.damop)
	c:RegisterEffect(e3)

	-- Attach self to 1 Xyz if sent to GY
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCondition(s.attcon)
	e4:SetTarget(s.atttg)
	e4:SetOperation(s.attop)
	c:RegisterEffect(e4)

	-- Material grant: Pay 1000 LP to declare attack
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_XMATERIAL+EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_ATTACK_COST)
	e5:SetCost(s.atkop)
	c:RegisterEffect(e5)

	-- Detach trigger: Destroy 1 Set card
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,1))
	e6:SetCategory(CATEGORY_DESTROY)
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e6:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e6:SetCode(EVENT_TO_GRAVE)
	e6:SetCondition(s.descon)
	e6:SetTarget(s.destg)
	e6:SetOperation(s.desop)
	c:RegisterEffect(e6)
end
s.listed_series={SET_PURRFECT}

function s.lockcon(e)
	return Duel.IsExistingMatchingCard(function(c,p) return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:GetOwner()==p end,e:GetHandlerPlayer(),0,LOCATION_MZONE,1,nil,e:GetHandlerPlayer())
end
function s.locklimit(e,re,tp)
	local tc=re:GetHandler()
	if not (tc and tc:IsFaceup() and tc:IsLocation(LOCATION_MZONE)) then return false end
	local g=Duel.GetMatchingGroup(function(c,p) return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:GetOwner()==p end,e:GetHandlerPlayer(),0,LOCATION_MZONE,nil,e:GetHandlerPlayer())
	local max_atk=g:GetMaxGroup(Card.GetAttack):GetFirst():GetAttack()
	return tc:GetAttack()>max_atk
end

function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(function(c) return c:IsControler(1-tp) and c:IsType(TYPE_XYZ) end,1,nil)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Damage(1-tp,800,REASON_EFFECT)
	Duel.Recover(tp,800,REASON_EFFECT)
end

function s.attcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_SZONE)
end
function s.atttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(function(c) return c:IsFaceup() and c:IsType(TYPE_XYZ) end,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
end
function s.attop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectMatchingCard(tp,function(c) return c:IsFaceup() and c:IsType(TYPE_XYZ) end,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	local tc=g:GetFirst()
	if tc and not tc:IsDead() then
		Duel.Overlay(tc,Group.FromCards(c))
	end
end

function s.atkop(e,c,tp)
	return Duel.CheckLPCost(tp,1000)
end

function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_OVERLAY) and (c:GetReason()&(REASON_COST|REASON_EFFECT))~=0
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsFacedown() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFacedown,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,Card.IsFacedown,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
