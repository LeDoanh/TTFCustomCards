--Federico, the Executor Sankta
--Embedded Laterano support; initialized once regardless of card load order.
if not LateranoSupport then
LateranoSupport={}
local H=LateranoSupport
H.AMMO=0x1f40
H.SANKTA=0x0f41
H.LIBERI=0x0f42
H.LATERANO=0x0f43
H.CITY=120261410
--Exusiai the New Covenant: card ID supplied by the user.
H.COVENANT=31700003
function H.Sankta(c) return c:IsMonster() and c:IsSetCard(H.SANKTA) end
function H.Liberi(c) return c:IsMonster() and c:IsSetCard(H.LIBERI) end
function H.Member(c) return H.Sankta(c) or H.Liberi(c) end
function H.FaceMember(c) return c:IsFaceup() and H.Member(c) end
function H.Spell(c) return c:IsSpell() and c:IsSetCard(H.LATERANO) end
function H.CanAmmo(tp,n,both,reason) return Duel.IsCanRemoveCounter(tp,1,both and 1 or 0,H.AMMO,n,reason or REASON_COST) end
function H.PayAmmo(tp,n,both,reason) return Duel.RemoveCounter(tp,1,both and 1 or 0,H.AMMO,n,reason or REASON_COST) end
function H.CityFilter(c,n) return c:IsFaceup() and c:IsCode(H.CITY) and c:IsCanAddCounter(H.AMMO,n) end
function H.CanPlace(tp,n) return Duel.IsExistingMatchingCard(H.CityFilter,tp,LOCATION_FZONE,0,1,nil,n) end
function H.Place(tp,n)
 if n<=0 then return false end
 local city=Duel.GetMatchingGroup(H.CityFilter,tp,LOCATION_FZONE,0,nil,n):GetFirst()
 if not city then return false end
 return city:AddCounter(H.AMMO,n)
end
function H.Level(c,source,value)
 if not c:IsFaceup() or not c:HasLevel() then return false end
 local e=Effect.CreateEffect(source)
 e:SetType(EFFECT_TYPE_SINGLE) e:SetCode(EFFECT_CHANGE_LEVEL)
 e:SetValue(value) e:SetReset(RESET_EVENT|RESETS_STANDARD) c:RegisterEffect(e)
 return c:IsLevel(value)
end
function H.AddHandSummon(c,id,reveal)
 local e=Effect.CreateEffect(c)
 e:SetDescription(aux.Stringid(id,0)) e:SetCategory(CATEGORY_SPECIAL_SUMMON)
 e:SetType(EFFECT_TYPE_IGNITION) e:SetRange(LOCATION_HAND)
 e:SetCountLimit(1,{id,0})
 local function revealfilter(tc) return H.Sankta(tc) and not tc:IsPublic() end
 e:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
  local canammo=H.CanAmmo(tp,1)
  local canreveal=reveal and Duel.IsExistingMatchingCard(revealfilter,tp,LOCATION_HAND,0,1,c)
  if chk==0 then return canammo or canreveal end
  local mode=1
  if canreveal then mode=Duel.SelectEffect(tp,{canammo,aux.Stringid(id,5)},{true,aux.Stringid(id,6)}) end
  if mode==1 then H.PayAmmo(tp,1) else
   Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
   local g=Duel.SelectMatchingCard(tp,revealfilter,tp,LOCATION_HAND,0,1,1,c)
   Duel.ConfirmCards(1-tp,g) Duel.ShuffleHand(tp)
  end
 end)
 e:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
  Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,LOCATION_HAND)
 end)
 e:SetOperation(function(e,tp) if c:IsRelateToEffect(e) then Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP) end end)
 c:RegisterEffect(e)
end
function H.AddSummon(c,id,desc,category,target,operation,cost,specialonly)
 local e=Effect.CreateEffect(c)
 e:SetDescription(aux.Stringid(id,desc)) e:SetCategory(category)
 e:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O) e:SetProperty(EFFECT_FLAG_DELAY)
 e:SetCode(specialonly and EVENT_SPSUMMON_SUCCESS or EVENT_SUMMON_SUCCESS)
 e:SetCountLimit(1,{id,1})
 if cost then e:SetCost(cost) end
 e:SetTarget(target) e:SetOperation(operation) c:RegisterEffect(e)
 if not specialonly then local b=e:Clone() b:SetCode(EVENT_SPSUMMON_SUCCESS) c:RegisterEffect(b) end
 return e
end
function H.SearchFilter(c,kind,level)
 local good=(kind=='sankta' and H.Sankta(c)) or (kind=='liberi' and H.Liberi(c))
  or (kind=='member' and H.Member(c)) or (kind=='anymember' and (c:IsSetCard(H.SANKTA) or c:IsSetCard(H.LIBERI)))
  or (kind=='spell' and H.Spell(c))
 return good and (not level or c:IsLevel(level)) and c:IsAbleToHand()
end
function H.Search(tp,kind,level,locations)
 Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
 local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(H.SearchFilter),tp,locations or LOCATION_DECK,0,1,1,nil,kind,level)
 if #g>0 then Duel.SendtoHand(g,nil,REASON_EFFECT) Duel.ConfirmCards(1-tp,g) end
end
function H.AddSearch(c,id,kind)
 H.AddSummon(c,id,1,CATEGORY_TOHAND|CATEGORY_SEARCH,
 function(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.IsExistingMatchingCard(H.SearchFilter,tp,LOCATION_DECK,0,1,nil,kind) end
  Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
 end,function(e,tp) H.Search(tp,kind) end)
end
function H.XyzFilter(c,mg) return c:IsXyzSummonable(nil,mg) end
function H.CanXyzTarget(tc,e,tp,level,checktarget)
 if tc==e:GetHandler() or not H.FaceMember(tc) or not tc:HasLevel()
  or (checktarget and not tc:IsCanBeEffectTarget(e)) then return false end
 local lv=level==0 and e:GetHandler():GetLevel() or level
 tc:AssumeProperty(ASSUME_LEVEL,lv)
 local mg=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
 local good=Duel.IsExistingMatchingCard(H.XyzFilter,tp,LOCATION_EXTRA,0,1,nil,mg)
 Duel.AssumeReset() return good
end
function H.ImmediateXyz(tp)
 local mg=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
 local g=Duel.GetMatchingGroup(H.XyzFilter,tp,LOCATION_EXTRA,0,nil,mg)
 if #g==0 then return end
 Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
 Duel.XyzSummon(tp,g:Select(tp,1,1,nil):GetFirst(),nil,mg)
end
function H.ActionFilter(c,action)
 if action=='spell' then return c:IsSpellTrap() end
 if action=='negate' then return c:IsFaceup() and c:IsNegatable() end
 if action=='bounce' then return c:IsAbleToHand() end
 if action=='lowdef' then return c:IsFaceup() and c:IsMonster() and not c:IsLinkMonster() and c:GetDefense()<=1500 end
 return false
end
function H.AddModeQuick(c,id,action,level,both)
 local e=Effect.CreateEffect(c)
 e:SetDescription(aux.Stringid(id,2)) e:SetType(EFFECT_TYPE_QUICK_O)
 e:SetCode(EVENT_FREE_CHAIN) e:SetRange(LOCATION_MZONE) e:SetCountLimit(1,{id,2})
 local ownloc=(action=='spell' or action=='negate') and LOCATION_ONFIELD or 0
 local function first(tp)
  if action=='ammo' then return H.CanPlace(tp,2) end
  return H.CanAmmo(tp,1,both) and Duel.IsExistingMatchingCard(H.ActionFilter,tp,ownloc,LOCATION_ONFIELD,1,nil,action)
 end
 local function second(e,tp)
  return Duel.IsExistingTarget(H.CanXyzTarget,tp,LOCATION_MZONE,0,1,nil,e,tp,level,true)
 end
 e:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
  local a,b=first(tp),second(e,tp)
  if chk==0 then return a or b end
  local op=Duel.SelectEffect(tp,{a,aux.Stringid(id,3)},{b,aux.Stringid(id,4)})
  e:SetLabel(op)
  e:SetProperty(op==2 and EFFECT_FLAG_CARD_TARGET or 0)
  if op==1 and action~='ammo' then H.PayAmmo(tp,1,both) end
 end)
 e:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
  if chkc then return e:GetLabel()==2 and chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and H.CanXyzTarget(chkc,e,tp,level,false) end
  if chk==0 then return true end
  if e:GetLabel()==2 then
   Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
   local g=Duel.SelectTarget(tp,H.CanXyzTarget,tp,LOCATION_MZONE,0,1,1,nil,e,tp,level,false)
   e:SetCategory(CATEGORY_LVCHANGE|CATEGORY_SPECIAL_SUMMON)
   Duel.SetOperationInfo(0,CATEGORY_LVCHANGE,g,1,tp,level==0 and c:GetLevel() or level)
   Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
  else
   local cat=action=='ammo' and 0 or action=='negate' and CATEGORY_DISABLE or action=='bounce' and CATEGORY_TOHAND or CATEGORY_DESTROY
   e:SetCategory(cat) if cat~=0 then Duel.SetOperationInfo(0,cat,nil,1,0,0) end
  end
 end)
 e:SetOperation(function(e,tp)
  if e:GetLabel()==2 then
   local tc=Duel.GetFirstTarget()
   local lv=level==0 and c:GetLevel() or level
   if tc and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) and H.Level(tc,c,lv) then H.ImmediateXyz(tp) end
  elseif action=='ammo' then H.Place(tp,2)
  else
   Duel.Hint(HINT_SELECTMSG,tp,action=='bounce' and HINTMSG_RTOHAND or action=='negate' and HINTMSG_FACEUP or HINTMSG_DESTROY)
   local tc=Duel.SelectMatchingCard(tp,H.ActionFilter,tp,ownloc,LOCATION_ONFIELD,1,1,nil,action):GetFirst()
   if not tc then return end
   if action=='bounce' then Duel.SendtoHand(tc,nil,REASON_EFFECT)
   elseif action=='negate' then tc:NegateEffects(c,nil,true)
   else Duel.Destroy(tc,REASON_EFFECT) end
  end
 end)
 c:RegisterEffect(e)
end
function H.AddCitySummonCounter(c,range,extra)
 local e=Effect.CreateEffect(c)
 e:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
 e:SetCode(EVENT_SUMMON_SUCCESS) e:SetRange(range)
 e:SetCondition(function(e,tp,eg)
  return (not extra or c:GetOverlayGroup():IsExists(Card.IsCode,1,nil,120261401)) and eg:IsExists(H.Member,1,nil)
 end)
 e:SetOperation(function(e,tp) if extra then H.Place(tp,1) else c:AddCounter(H.AMMO,1) end end)
 c:RegisterEffect(e)
 local b=e:Clone() b:SetCode(EVENT_SPSUMMON_SUCCESS) c:RegisterEffect(b)
end
function H.ChooseNumber(tp,max)
 local nums={} for i=1,max do nums[#nums+1]=i end
 return Duel.AnnounceNumber(tp,table.unpack(nums))
end
function H.NewQuick(c,description,category,cost,target,operation,count,code,flags)
 local e=Effect.CreateEffect(c)
 e:SetDescription(description) e:SetCategory(category)
 e:SetType(EFFECT_TYPE_QUICK_O) e:SetCode(EVENT_FREE_CHAIN) e:SetRange(LOCATION_MZONE)
 if count then if code then e:SetCountLimit(count,code,flags or 0) else e:SetCountLimit(count) end end
 if cost then e:SetCost(cost) end
 if target then e:SetTarget(target) end
 e:SetOperation(operation) c:RegisterEffect(e) return e
end
function H.HasCovenantMaterial(c) return c:IsCode(H.COVENANT) and c:GetOverlayGroup():IsExists(Card.IsCode,1,nil,120261404) end
function H.InstallCovenantSuppression()
 if H.CovenantMonitor then return end
 H.CovenantMonitor=true
 local wrapped={}
 local e=Effect.GlobalEffect()
 e:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS) e:SetCode(EVENT_ADJUST)
 e:SetOperation(function()
  local g=Duel.GetMatchingGroup(Card.IsCode,0,LOCATION_MZONE,LOCATION_MZONE,nil,H.COVENANT)
  for tc in g:Iter() do
   local first
   for _,ef in ipairs({tc:GetOwnEffects()}) do
    if ef:GetOwner()==tc and not ef:IsHasType(EFFECT_TYPE_XMATERIAL)
     and ef:IsHasType(EFFECT_TYPE_IGNITION|EFFECT_TYPE_QUICK_O|EFFECT_TYPE_QUICK_F|EFFECT_TYPE_TRIGGER_O|EFFECT_TYPE_TRIGGER_F|EFFECT_TYPE_ACTIVATE)
     and (not first or ef:GetFieldID()<first:GetFieldID()) then first=ef end
   end
   if first and not wrapped[first] then
    wrapped[first]=true local old=first:GetCondition()
    first:SetCondition(function(ef,...) return not H.HasCovenantMaterial(ef:GetHandler()) and (not old or old(ef,...)) end)
   end
  end
 end)
 Duel.RegisterEffect(e,0)
end
end
local H=LateranoSupport
local s,id=GetID()
function s.initial_effect(c)
 H.AddHandSummon(c,id,true)
 H.AddSearch(c,id,"sankta")
 H.AddModeQuick(c,id,"negate",7,true)
end
