--Artifact Excalibur
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--2+ Level 5 LIGHT monsters, or the once-per-turn alternate procedure.
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_LIGHT),5,2,s.ovfilter,
		aux.Stringid(id,0),Xyz.InfiniteMats,s.xyzop)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_ONFIELD,0)
	e1:SetTarget(function(e,c) return c:IsFaceup() and c:IsSetCard(SET_ARTIFACT) end)
	e1:SetValue(function(e,re,rp) return rp==1-e:GetHandlerPlayer() end)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,0})
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E|TIMING_END_PHASE)
	e2:SetCondition(function(e,tp) return Duel.IsTurnPlayer(1-tp) end)
	e2:SetCost(s.descost)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_SET)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(s.setcon)
	e3:SetTarget(s.settg)
	e3:SetOperation(s.setop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_ARTIFACT}
function s.ovfilter(c,tp,xyzc)
	return c:IsFaceup() and c:IsSetCard(SET_ARTIFACT,xyzc,SUMMON_TYPE_XYZ,tp)
		and c:IsType(TYPE_XYZ|TYPE_LINK,xyzc,SUMMON_TYPE_XYZ,tp)
end
function s.xyzop(e,tp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
	return true
end
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFacedown,tp,LOCATION_SZONE,0,2,nil)
		and Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,0,LOCATION_ONFIELD,2,nil) end
	local g=Duel.GetMatchingGroup(Card.IsFacedown,tp,LOCATION_SZONE,0,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,2,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,1-tp,LOCATION_ONFIELD)
end
function s.desop(e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local available=Duel.GetMatchingGroup(Card.IsFacedown,tp,LOCATION_SZONE,0,nil)
	local ct=math.min(2,#available)
	if ct==0 then return end
	local g=available:Select(tp,ct,ct,nil)
	Duel.HintSelection(g)
	if Duel.Destroy(g,REASON_EFFECT)==0 then return end
	--Count only cards actually destroyed, not attempted destruction.
	local ct=Duel.GetOperatedGroup():FilterCount(Card.IsReason,nil,REASON_DESTROY)
	if ct==0 then return end
	local og=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,0,LOCATION_ONFIELD,nil)
	ct=math.min(ct,#og)
	if ct==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local sg=og:Select(tp,ct,ct,nil)
	Duel.HintSelection(sg)
	Duel.SendtoGrave(sg,REASON_EFFECT)
end
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsPreviousControler(tp) and c:IsSummonType(SUMMON_TYPE_XYZ)
end
function s.setfilter(c)
	if not (c:IsSetCard(SET_ARTIFACT) and c:IsMonster())
		or (c:IsLocation(LOCATION_REMOVED) and c:IsFacedown()) then return false end
	if c:IsSSetable(true) then return true end
	if not c:IsType(TYPE_EXTRA) or c:IsForbidden() or c:IsHasEffect(EFFECT_CANNOT_SSET) then return false end
	for _,pe in ipairs({Duel.GetPlayerEffect(c:GetControler(),EFFECT_CANNOT_SSET)}) do
		local tg=pe:GetTarget()
		if not tg or tg(pe,c,c:GetControler()) then return false end
	end
	return true
end
function s.setasSpell(tp,g)
	local temp={}
	for tc in g:Iter() do
		if not tc:IsHasEffect(EFFECT_MONSTER_SSET) then
			local se=Effect.CreateEffect(tc)
			se:SetType(EFFECT_TYPE_SINGLE)
			se:SetCode(EFFECT_MONSTER_SSET)
			se:SetValue(TYPE_SPELL)
			se:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			tc:RegisterEffect(se)
			table.insert(temp,se)
		end
	end
	Duel.SSet(tp,g)
	for _,se in ipairs(temp) do se:Reset() end
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.setfilter),tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SET,nil,1,tp,LOCATION_GRAVE|LOCATION_REMOVED)
end
function s.setop(e,tp)
	local ft=math.min(2,(Duel.GetLocationCount(tp,LOCATION_SZONE)))
	if ft<=0 then return end
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.setfilter),tp,LOCATION_GRAVE|LOCATION_REMOVED,0,nil)
	if #g==0 then return end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,ft,aux.dncheck,1,tp,HINTMSG_SET)
	if #sg>0 then s.setasSpell(tp,sg) end
end
