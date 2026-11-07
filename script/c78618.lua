-- Velvetect Danse Macabre
local s,id=GetID()
function s.initial_effect(c)
	-- Activate: Detach any number of materials; destroy opponent cards
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)

	-- Hand trap condition: opponent controls an Xyz Monster you own
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(function(e) return Duel.IsExistingMatchingCard(function(c,tp) return c:IsType(TYPE_XYZ) and c:GetOwner()==tp end,e:GetHandlerPlayer(),0,LOCATION_MZONE,1,nil,e:GetHandlerPlayer()) end)
	c:RegisterEffect(e2)

	-- Material Effect: Opponent pays 500 LP to activate cards/effects
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_XMATERIAL)
	e3:SetCode(EFFECT_ACTIVATION_COST)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(0,1)
	e3:SetCost(function(e,te,tp) return Duel.CheckLPCost(tp,500) end)
	e3:SetOperation(function(e,tp,eg,ep,ev,re,r,rp) Duel.PayLPCost(tp,500) end)
	c:RegisterEffect(e3)

	-- Detach Effect: Set this card from GY, banish it when leaves
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,{id,1})
	e4:SetCondition(s.setcon)
	e4:SetTarget(s.settg)
	e4:SetOperation(s.setop)
	c:RegisterEffect(e4)
end
s.listed_series={0x786}

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(function(c) return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:GetOverlayCount()>0 end,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local opp_cards=Duel.GetMatchingGroup(nil,tp,0,LOCATION_ONFIELD,nil)
	if chk==0 then return #g>0 and #opp_cards>0 end
	local total_mat=0
	for tc in aux.Next(g) do total_mat=total_mat+tc:GetOverlayCount() end
	local max_detach=math.min(total_mat,#opp_cards)
	
	local count=0
	while count<max_detach do
		local sel_g=g:Filter(function(c) return c:CheckRemoveOverlayCard(tp,1,REASON_COST) end,nil)
		if #sel_g==0 then break end
		if count>0 and not Duel.SelectYesNo(tp,aux.Stringid(id,0)) then break end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DEATTACHFROM)
		local tc=sel_g:Select(tp,1,1,nil):GetFirst()
		tc:RemoveOverlayCard(tp,1,1,REASON_COST)
		count=count+1
	end
	e:SetLabel(count)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local count=e:GetLabel()
	local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_ONFIELD,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,count,0,0)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local count=e:GetLabel()
	local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_ONFIELD,nil)
	if #g>0 and count>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local sg=g:Select(tp,count,count,nil)
		Duel.Destroy(sg,REASON_EFFECT)
	end
end

function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_COST) and re:IsActivated() and re:IsActiveType(TYPE_XYZ)
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	return chk==0 and c:IsSSetable()
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsSSetable() then
		Duel.SSet(tp,c)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1)
	end
end
