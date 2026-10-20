--Inzektor Aiming
--Local support: this card has no custom helper-file dependency.
local H={}
function H.Faceup(c)
	return c:IsFaceup() and c:IsSetCard(SET_INZEKTOR)
end
function H.Monster(c)
	return c:IsSetCard(SET_INZEKTOR) and c:IsMonster() and not c:IsForbidden()
end
function H.STCount(tp)
	return Duel.GetMatchingGroupCount(H.Faceup,tp,LOCATION_STZONE,0,nil)
end
function H.EquipEvent(e,tp,eg)
	return eg:IsExists(function(c) return c:IsSetCard(SET_INZEKTOR) and c:GetEquipTarget()~=nil end,1,nil)
end
function H.SPFilter(c,e,tp)
	return H.Monster(c) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function H.RevivableCostMonster(c,e,tp)
	--A field monster cannot pass IsCanBeSpecialSummoned until it has paid the cost.
	if not c:IsOriginalType(TYPE_MONSTER) or c:IsForbidden()
		or c:IsHasEffect(EFFECT_CANNOT_SPECIAL_SUMMON)
		or (c:IsHasEffect(EFFECT_REVIVE_LIMIT) and not c:IsStatus(STATUS_PROC_COMPLETE)) then return false end
	if c:IsLocation(LOCATION_MZONE) then
		return not c:IsHasEffect(EFFECT_SPSUMMON_CONDITION)
			and Duel.IsPlayerCanSpecialSummon(tp,0,POS_FACEUP,tp,c)
	end
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function H.SendSummonCostFilter(c,e,tp,source_locations)
	if not (c:IsSetCard(SET_INZEKTOR) and (c:IsFaceup() or c:IsLocation(LOCATION_HAND))
		and c:IsAbleToGraveAsCost()) or Duel.GetMZoneCount(tp,c)<=0 then return false end
	return Duel.IsExistingMatchingCard(aux.NecroValleyFilter(H.SPFilter),tp,source_locations,0,1,nil,e,tp)
		or H.RevivableCostMonster(c,e,tp)
end
function H.SendSummonCost(e,tp,chk,cost_locations,source_locations)
	if chk==0 then return Duel.IsExistingMatchingCard(H.SendSummonCostFilter,tp,cost_locations,0,1,nil,e,tp,source_locations) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,H.SendSummonCostFilter,tp,cost_locations,0,1,1,nil,e,tp,source_locations)
	Duel.SendtoGrave(g,REASON_COST)
end
local s,id=GetID()
s.listed_series={SET_INZEKTOR}
function s.initial_effect(c)
	local act=Effect.CreateEffect(c) act:SetType(EFFECT_TYPE_ACTIVATE) act:SetCode(EVENT_FREE_CHAIN) c:RegisterEffect(act)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION) e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,{id,0})
	e1:SetCost(s.cost) e1:SetTarget(s.sptg) e1:SetOperation(s.spop) c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O) e2:SetCode(EVENT_EQUIP)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(H.EquipEvent) e2:SetTarget(s.destg) e2:SetOperation(s.desop) c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD) e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_SZONE) e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(function(e,c) return H.Faceup(c) end)
	e3:SetValue(function(e) return H.STCount(e:GetHandlerPlayer())*300 end)
	c:RegisterEffect(e3)
	local e4=e3:Clone() e4:SetCode(EFFECT_UPDATE_DEFENSE) c:RegisterEffect(e4)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk) return H.SendSummonCost(e,tp,chk,LOCATION_HAND|LOCATION_ONFIELD,LOCATION_DECK|LOCATION_GRAVE) end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
end
function s.spop(e,tp)
	local c=e:GetHandler()
	if not (c:IsFaceup() and c:IsRelateToEffect(e)) or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(H.SPFilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP) end
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.desop(e,tp)
	local c=e:GetHandler()
	if not (c:IsFaceup() and c:IsRelateToEffect(e)) then return end
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then Duel.Destroy(tc,REASON_EFFECT) end
end
