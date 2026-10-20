--Inzektor Arsenel
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
local s,id=GetID()
s.listed_series={SET_INZEKTOR}
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.acttg)
	e1:SetOperation(s.actop)
	c:RegisterEffect(e1)
	local lock=Effect.CreateEffect(c)
	lock:SetType(EFFECT_TYPE_FIELD)
	lock:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	lock:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	lock:SetRange(LOCATION_FZONE)
	lock:SetTargetRange(1,0)
	lock:SetTarget(function(e,c) return not c:IsRace(RACE_INSECT) end)
	c:RegisterEffect(lock)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetRange(LOCATION_FZONE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetTarget(s.eqtg)
	e2:SetOperation(s.eqop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_FZONE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetTarget(s.tdtg)
	e4:SetOperation(s.tdop)
	c:RegisterEffect(e4)
end
function s.thfilter(c) return H.Monster(c) and c:IsAbleToHand() end
function s.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	e:SetLabel(0)
	if Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		e:SetLabel(1)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	end
end
function s.actop(e,tp)
	local c=e:GetHandler()
	if e:GetLabel()==0 or not (c:IsFaceup() and c:IsRelateToEffect(e)) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then Duel.SendtoHand(g,nil,REASON_EFFECT) Duel.ConfirmCards(1-tp,g) end
end
function s.eqfilter(c,name,tp)
	if not H.Monster(c) or c:IsCode(name) then return false end
	for _,used in ipairs({Duel.GetFlagEffectLabel(tp,id)}) do if c:IsCode(used) then return false end end
	return true
end
function s.summoned(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(SET_INZEKTOR)
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.eqfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil,c:GetCode(),tp)
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and eg:IsExists(s.summoned,1,nil,e,tp) end
	local g=eg:Filter(s.summoned,nil,e,tp)
	for mc in g:Iter() do mc:CreateEffectRelation(e) end
	g:KeepAlive()
	e:SetLabelObject(g)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
end
function s.eqop(e,tp)
	local stored=e:GetLabelObject()
	if not stored then return end
	local g=stored:Filter(function(c) return c:IsRelateToEffect(e) and c:IsFaceup() and c:IsLocation(LOCATION_MZONE) end,nil)
	for mc in stored:Iter() do mc:ReleaseEffectRelation(e) end
	stored:DeleteGroup()
	local c=e:GetHandler()
	if not (c:IsRelateToEffect(e) and c:IsFaceup()) or #g==0 or Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local mc=g:Select(tp,1,1,nil):GetFirst()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local ec=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.eqfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil,mc:GetCode(),tp):GetFirst()
	if ec and H.Equip(e,tp,ec,mc) then Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1,ec:GetCode()) end
end
function s.tdfilter(c)
	return H.Monster(c) and c:IsAbleToDeck() and (not c:IsLocation(LOCATION_REMOVED) or c:IsFaceup())
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE|LOCATION_REMOVED) and s.tdfilter(chkc) end
	if chk==0 then return e:GetHandler():IsAbleToDeck() and Duel.IsPlayerCanDraw(tp,2)
		and Duel.IsExistingTarget(aux.NecroValleyFilter(s.tdfilter),tp,LOCATION_GRAVE|LOCATION_REMOVED,0,4,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,aux.NecroValleyFilter(s.tdfilter),tp,LOCATION_GRAVE|LOCATION_REMOVED,0,4,4,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,5,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
function s.tdop(e,tp)
	local c=e:GetHandler()
	local g=Duel.GetTargetCards(e)
	if not (c:IsRelateToEffect(e) and c:IsFaceup()) or #g~=4 then return end
	g:AddCard(c)
	Duel.SendtoDeck(g,nil,SEQ_DECKTOP,REASON_EFFECT)
	local moved=Duel.GetOperatedGroup()
	if moved:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
	if moved:FilterCount(Card.IsLocation,nil,LOCATION_DECK|LOCATION_EXTRA)==5 then Duel.BreakEffect() Duel.Draw(tp,2,REASON_EFFECT) end
end
