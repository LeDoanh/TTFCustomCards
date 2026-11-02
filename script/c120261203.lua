--Inzektor Palaeodictyoptera
--Local support: this card has no custom helper-file dependency.
local H={}
function H.Faceup(c)
	return c:IsFaceup() and c:IsSetCard(SET_INZEKTOR)
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
local s,id=GetID()
s.listed_series={SET_INZEKTOR}
function s.initial_effect(c)
	c:EnableReviveLimit()
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_INSECT),7,2)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.stat)
	c:RegisterEffect(e1)
	local e1b=e1:Clone() e1b:SetCode(EFFECT_UPDATE_DEFENSE) c:RegisterEffect(e1b)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(Cost.DetachFromSelf(1))
	e2:SetTarget(s.eqtg)
	e2:SetOperation(s.eqop)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_EQUIP)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCountLimit(1,id)
	e3:SetCondition(H.EquipEvent)
	e3:SetTarget(s.efftg)
	e3:SetOperation(s.effop)
	c:RegisterEffect(e3)
end
function s.stat(e) return Duel.GetMatchingGroupCount(H.Faceup,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,nil)*1000 end
function s.eqfilter(c,e) return not c:IsImmuneToEffect(e) and not c:IsForbidden() end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.IsExistingMatchingCard(s.eqfilter,tp,0,LOCATION_ONFIELD,1,nil,e) end
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,1-tp,LOCATION_ONFIELD)
end
function s.eqop(e,tp)
	local c=e:GetHandler()
	if not (c:IsFaceup() and c:IsRelateToEffect(e)) or Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local ec=Duel.SelectMatchingCard(tp,s.eqfilter,tp,0,LOCATION_ONFIELD,1,1,nil,e):GetFirst()
	if ec then H.Equip(e,tp,ec,c,true) end
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local can_draw=Duel.IsPlayerCanDraw(tp,2)
	local op=Duel.SelectEffect(tp,{can_draw,aux.Stringid(id,2)},{true,aux.Stringid(id,3)})
	e:SetLabel(op)
	if op==1 then e:SetCategory(CATEGORY_DRAW) Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2) else e:SetCategory(0) end
end
function s.effop(e,tp)
	if e:GetLabel()==1 then Duel.Draw(tp,2,REASON_EFFECT) return end
	--A lingering field effect also covers Inzektor cards controlled later this turn.
	for _,code in ipairs({EFFECT_INDESTRUCTABLE_BATTLE,EFFECT_INDESTRUCTABLE_EFFECT,EFFECT_CANNOT_REMOVE}) do
		local pe=Effect.CreateEffect(e:GetHandler())
		pe:SetType(EFFECT_TYPE_FIELD)
		pe:SetCode(code)
		pe:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		pe:SetTargetRange(LOCATION_ONFIELD,0)
		pe:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_INZEKTOR))
		pe:SetValue(1)
		pe:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(pe,tp)
	end
end
