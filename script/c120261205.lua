--Inzektor Tarantura
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
local s,id=GetID()
s.listed_series={SET_INZEKTOR}
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,{id,0})
	e1:SetTarget(s.destg) e1:SetOperation(s.desop) c:RegisterEffect(e1)
	local e1b=e1:Clone() e1b:SetCode(EVENT_SPSUMMON_SUCCESS) c:RegisterEffect(e1b)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.eqtg) e2:SetOperation(s.eqop) c:RegisterEffect(e2)
	--The text has no player restriction: protect Inzektor activations on either side.
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD) e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EFFECT_CANNOT_INACTIVATE)
	e3:SetCondition(s.equipped) e3:SetValue(s.chainprotect) c:RegisterEffect(e3)
	local e4=e3:Clone() e4:SetCode(EFFECT_CANNOT_DISEFFECT) c:RegisterEffect(e4)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD) e5:SetRange(LOCATION_SZONE)
	e5:SetCode(EFFECT_CANNOT_DISABLE)
	e5:SetCondition(s.equipped)
	e5:SetTargetRange(LOCATION_ALL,LOCATION_ALL)
	e5:SetTarget(function(e,c) return c:IsSetCard(SET_INZEKTOR) end)
	c:RegisterEffect(e5)
end
function s.equipped(e) return e:GetHandler():GetEquipTarget()~=nil end
function s.chainprotect(e,ct)
	local re=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT)
	return re and re:GetHandler():IsSetCard(SET_INZEKTOR)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() end
	if chk==0 then return H.STCount(tp)>0 and Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,H.STCount(tp),nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.desop(e,tp) Duel.Destroy(Duel.GetTargetCards(e),REASON_EFFECT) end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(H.Faceup,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(H.Monster),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
end
function s.eqop(e,tp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local mc=Duel.SelectMatchingCard(tp,H.Faceup,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
	if not mc then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local ec=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(H.Monster),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil):GetFirst()
	if ec then H.Equip(e,tp,ec,mc) end
end
