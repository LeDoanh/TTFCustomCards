--Inzektor Trilobite
--Local support: this card has no custom helper-file dependency.
local H={}
function H.Faceup(c)
	return c:IsFaceup() and c:IsSetCard(SET_INZEKTOR)
end
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
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,function(c) return c:IsRace(RACE_INSECT) end)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_QUICK_O) e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND|LOCATION_GRAVE)
	e1:SetCountLimit(1,{id,0}) e1:SetCost(s.spcost) e1:SetTarget(s.sptg) e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_LVCHANGE+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O) e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(function(e) return e:GetHandler():GetEquipTarget()~=nil end)
	e2:SetCost(s.xyzcost) e2:SetTarget(s.xyztg) e2:SetOperation(s.xyzop)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O) e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCountLimit(1,{id,2})
	e3:SetCondition(function(e) return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD) end)
	e3:SetCost(s.oathcost) e3:SetTarget(s.thtg) e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
function s.oathcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	local lock=Effect.CreateEffect(e:GetHandler())
	lock:SetType(EFFECT_TYPE_FIELD) lock:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	lock:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	lock:SetTargetRange(1,0)
	lock:SetTarget(function(e,c) return not c:IsRace(RACE_INSECT) end)
	lock:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(lock,tp)
end
function s.costfilter(c) return c:IsSetCard(SET_INZEKTOR) and c:IsAbleToGraveAsCost() end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return s.oathcost(e,tp,eg,ep,ev,re,r,rp,0)
		and Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	s.oathcost(e,tp,eg,ep,ev,re,r,rp,1)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND,0,1,1,e:GetHandler())
	Duel.SendtoGrave(g,REASON_COST)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(H.SPFilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,tp,e:GetHandler():GetLocation())
end
function s.spop(e,tp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local mc=Duel.SelectMatchingCard(tp,H.SPFilter,tp,LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
	if not mc or Duel.SpecialSummon(mc,0,tp,tp,false,false,POS_FACEUP)==0 then return end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsLocation(LOCATION_HAND|LOCATION_GRAVE) then Duel.BreakEffect() H.Equip(e,tp,c,mc) end
end
function s.levelmonster(c) return H.Faceup(c) and c:HasLevel() end
function s.xyzfilter(c,mg) return c:IsRace(RACE_INSECT) and c:IsXyzSummonable(nil,mg) end
function s.options(tp)
	local mg=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	local lg=mg:Filter(s.levelmonster,nil)
	local opts={}
	if #lg==0 then return opts end
	for level=1,8 do
		for tc in lg:Iter() do tc:AssumeProperty(ASSUME_LEVEL,level) end
		if Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_EXTRA,0,1,nil,mg) then table.insert(opts,level) end
		Duel.AssumeReset()
	end
	return opts
end
function s.xyzcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() and s.oathcost(e,tp,eg,ep,ev,re,r,rp,0) and #s.options(tp)>0 end
	s.oathcost(e,tp,eg,ep,ev,re,r,rp,1)
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
	local opts=s.options(tp)
	local level=Duel.AnnounceNumber(tp,table.unpack(opts))
	e:SetLabel(level)
end
function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_LVCHANGE,nil,0,tp,e:GetLabel())
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.xyzop(e,tp)
	local g=Duel.GetMatchingGroup(s.levelmonster,tp,LOCATION_MZONE,0,nil)
	if #g==0 then return end
	local changed=false
	for tc in g:Iter() do
		if not tc:IsImmuneToEffect(e) then
			local lv=Effect.CreateEffect(e:GetHandler())
			lv:SetType(EFFECT_TYPE_SINGLE) lv:SetCode(EFFECT_CHANGE_LEVEL)
			lv:SetValue(e:GetLabel()) lv:SetReset(RESET_EVENT|RESETS_STANDARD)
			tc:RegisterEffect(lv)
			changed=true
		end
	end
	if not changed then return end
	local mg=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	local xg=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_EXTRA,0,nil,mg)
	if #xg==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=xg:Select(tp,1,1,nil):GetFirst()
	Duel.XyzSummon(tp,sc,nil,mg)
end
function s.thfilter(c) return H.Monster(c) and c:IsAbleToHand() end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
end
function s.thop(e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then Duel.SendtoHand(g,nil,REASON_EFFECT) Duel.ConfirmCards(1-tp,g) end
end
