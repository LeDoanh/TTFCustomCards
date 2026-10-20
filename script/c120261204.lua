--Inzektor Take Form
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
function H.Equip(e,tp,ec,mc,make_inzektor)
	if not (mc and mc:IsFaceup() and mc:IsLocation(LOCATION_MZONE))
		or Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or ec:IsForbidden() then return false end
	--Duel.Equip alone leaves an existing Spell/Trap on its original side.
	--Absorbed Spell/Traps are placed in the absorbing player's Spell/Trap Zone.
	if make_inzektor and ec:IsLocation(LOCATION_SZONE) then
		local typ=Effect.CreateEffect(e:GetHandler())
		typ:SetType(EFFECT_TYPE_SINGLE)
		typ:SetCode(EFFECT_CHANGE_TYPE)
		typ:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		typ:SetValue(ec:IsTrap() and (TYPE_TRAP|TYPE_EQUIP) or (TYPE_SPELL|TYPE_EQUIP))
		typ:SetReset(RESET_EVENT|RESETS_STANDARD)
		ec:RegisterEffect(typ)
		if not Duel.MoveToField(ec,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then typ:Reset() return false end
	end
	if not Duel.Equip(tp,ec,mc,true,true) then return false end
	local limit=Effect.CreateEffect(ec)
	limit:SetType(EFFECT_TYPE_SINGLE)
	limit:SetCode(EFFECT_EQUIP_LIMIT)
	limit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	limit:SetLabelObject(mc)
	limit:SetValue(function(e,c) return c==e:GetLabelObject() end)
	limit:SetReset(RESET_EVENT|RESETS_STANDARD)
	ec:RegisterEffect(limit)
	if make_inzektor then
		local set=Effect.CreateEffect(e:GetHandler())
		set:SetType(EFFECT_TYPE_SINGLE)
		set:SetCode(EFFECT_ADD_SETCODE)
		set:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		set:SetValue(SET_INZEKTOR)
		set:SetReset(RESET_EVENT|RESETS_STANDARD)
		ec:RegisterEffect(set)
	end
	--Publish EVENT_EQUIP after its new type/archetype and equip limit are installed.
	Duel.EquipComplete()
	return ec:GetEquipTarget()==mc
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
	local act=Effect.CreateEffect(c)
	act:SetType(EFFECT_TYPE_ACTIVATE) act:SetCode(EVENT_FREE_CHAIN) c:RegisterEffect(act)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,{id,0})
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--It may also be applied in the same Chain Link as this Trap's activation.
	local activate_effect=e1:Clone()
	activate_effect:SetType(EFFECT_TYPE_ACTIVATE)
	c:RegisterEffect(activate_effect)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_EQUIP)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(H.EquipEvent)
	e2:SetTarget(s.negtg)
	e2:SetOperation(s.negop)
	c:RegisterEffect(e2)
	local shield=Effect.CreateEffect(c)
	shield:SetType(EFFECT_TYPE_FIELD)
	shield:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	shield:SetRange(LOCATION_SZONE)
	shield:SetTargetRange(LOCATION_STZONE,0)
	shield:SetTarget(function(e,c) return H.Faceup(c) end)
	shield:SetValue(function(e,re) return re:GetHandler()~=e:GetHandler() end)
	c:RegisterEffect(shield)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk) return H.SendSummonCost(e,tp,chk,LOCATION_ONFIELD,LOCATION_GRAVE) end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
end
function s.spop(e,tp)
	local c=e:GetHandler()
	if not (c:IsFaceup() and c:IsRelateToEffect(e)) or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local mc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(H.SPFilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
	if not mc or Duel.SpecialSummon(mc,0,tp,tp,false,false,POS_FACEUP)==0 then return end
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or not Duel.IsExistingMatchingCard(aux.NecroValleyFilter(H.Monster),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil)
		or not Duel.SelectYesNo(tp,aux.Stringid(id,2)) then return end
	Duel.BreakEffect()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local ec=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(H.Monster),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil):GetFirst()
	if ec then H.Equip(e,tp,ec,mc) end
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsFaceup() end
	if chk==0 then return H.STCount(tp)>0 and Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,H.STCount(tp),nil)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,#g,0,0)
end
function s.negop(e,tp)
	local c=e:GetHandler()
	if not (c:IsFaceup() and c:IsRelateToEffect(e)) then return end
	for tc in Duel.GetTargetCards(e):Iter() do if tc:IsFaceup() then tc:NegateEffects(c,nil,true) end end
end
