--Inzektor Monarch
--Local support: this card has no custom helper-file dependency.
local H={}
function H.Monster(c)
	return c:IsSetCard(SET_INZEKTOR) and c:IsMonster() and not c:IsForbidden()
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
local s,id=GetID()
s.listed_series={SET_INZEKTOR}
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND|LOCATION_GRAVE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,{id,0})
	e1:SetTarget(s.eqtg)
	e1:SetOperation(s.eqop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(function(e) return e:GetHandler():GetEquipTarget()~=nil end)
	e2:SetCost(Cost.SelfToGrave)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCountLimit(1,{id,2})
	e3:SetCondition(function(e) return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD) end)
	e3:SetTarget(s.placetg)
	e3:SetOperation(s.placeop)
	c:RegisterEffect(e3)
end
function s.host(c) return c:IsFaceup() and c:IsSetCard(SET_INZEKTOR) end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.host(chkc) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingTarget(s.host,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectTarget(tp,s.host,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,tp,e:GetHandler():GetLocation())
end
function s.eqop(e,tp)
	local c=e:GetHandler()
	local mc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsLocation(LOCATION_HAND|LOCATION_GRAVE) and mc and mc:IsRelateToEffect(e) then H.Equip(e,tp,c,mc) end
end
function s.same(c,code) return c:IsFaceup() and c:IsSetCard(SET_INZEKTOR) and c:IsCode(code) end
function s.spfilter(c,e,tp)
	return H.SPFilter(c,e,tp) and not Duel.IsExistingMatchingCard(s.same,tp,LOCATION_MZONE,0,1,nil,c:GetCode())
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_GRAVE)
end
function s.spop(e,tp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local mc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
	if not mc or Duel.SpecialSummon(mc,0,tp,tp,false,false,POS_FACEUP)==0 or Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.BreakEffect()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local ec=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(H.Monster),tp,LOCATION_GRAVE,0,1,1,nil):GetFirst()
	if ec then H.Equip(e,tp,ec,mc) end
end
function s.placefilter(c)
	return c:IsSetCard(SET_INZEKTOR) and c:IsSpellTrap() and c:IsType(TYPE_CONTINUOUS) and not c:IsForbidden()
end
function s.placetg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.IsExistingMatchingCard(s.placefilter,tp,LOCATION_DECK,0,1,nil) end
end
function s.placeop(e,tp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local tc=Duel.SelectMatchingCard(tp,s.placefilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if tc then Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true) end
end
