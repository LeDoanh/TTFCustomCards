--Veilstrike Grand Entrance!
local s,id=GetID()
local SET_VEILSTRIKE=0x7f1
s.listed_series={SET_VEILSTRIKE}
function s.initial_effect(c)
 --Native hand-activation permission, separate from an external permission.
 local permission=Effect.CreateEffect(c)
 permission:SetDescription(aux.Stringid(id,1))
 permission:SetType(EFFECT_TYPE_SINGLE)
 permission:SetCode(EFFECT_TRAP_ACT_IN_HAND)
 permission:SetCondition(s.handcon)
 permission:SetValue(function(e,c) e:SetLabel(1) end)
 c:RegisterEffect(permission)
 local e1=Effect.CreateEffect(c)
 e1:SetDescription(aux.Stringid(id,0))
 e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
 e1:SetType(EFFECT_TYPE_ACTIVATE)
 e1:SetCode(EVENT_FREE_CHAIN)
 e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
 e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E|TIMING_END_PHASE)
 e1:SetCost(s.handcost)
 e1:SetLabelObject(permission)
 e1:SetTarget(s.target)
 e1:SetOperation(s.activate)
 c:RegisterEffect(e1)
 --No once-per-turn restriction is printed for this discarded-card effect.
 local e2=Effect.CreateEffect(c)
 e2:SetDescription(aux.Stringid(id,2))
 e2:SetCategory(CATEGORY_DRAW)
 e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
 e2:SetCode(EVENT_DISCARD)
 e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
 e2:SetCondition(s.drawcon)
 e2:SetTarget(s.drawtg)
 e2:SetOperation(s.drawop)
 c:RegisterEffect(e2)
end

function s.handcon(e)
 local c=e:GetHandler()
 return Duel.IsExistingMatchingCard(Card.IsDiscardable,c:GetControler(),LOCATION_HAND,0,1,c)
end
function s.handcost(e,tp,eg,ep,ev,re,r,rp,chk)
 local permission=e:GetLabelObject()
 if chk==0 then permission:SetLabel(0) return true end
 if permission:GetLabel()==1 then
  permission:SetLabel(0)
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
  local g=Duel.SelectMatchingCard(tp,Card.IsDiscardable,tp,LOCATION_HAND,0,1,1,e:GetHandler())
  Duel.SendtoGrave(g,REASON_COST|REASON_DISCARD)
 end
end
function s.fromhand(e)
 return e:GetHandler():IsStatus(STATUS_ACT_FROM_HAND) and 1 or 0
end
function s.drawcon(e,tp,eg,ep,ev,re,r,rp)
 return e:GetHandler():IsReason(REASON_COST) and re and re:IsActivated()
end
function s.drawtg(e,tp,eg,ep,ev,re,r,rp,chk)
 if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
 Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.drawop(e,tp)
 Duel.Draw(tp,1,REASON_EFFECT)
end

function s.spfilter(c,e,tp)
 return c:IsSetCard(SET_VEILSTRIKE) and c:IsMonster()
  and (not c:IsLocation(LOCATION_REMOVED) or c:IsFaceup())
  and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
 if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
  and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil,e,tp) end
 e:SetLabel(s.fromhand(e))
 Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE|LOCATION_REMOVED)
end
function s.activate(e,tp)
 if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
 Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
 local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE|LOCATION_REMOVED,0,1,1,nil,e,tp)
 if #g==0 or Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)==0 or e:GetLabel()~=1 then return end
 --Lingering protection applies to Veilstrike monsters in this player's possession,
 --including monsters obtained later this turn, and is not limited to the field.
 local shield=Effect.CreateEffect(e:GetHandler())
 shield:SetDescription(aux.Stringid(id,3))
 shield:SetType(EFFECT_TYPE_FIELD)
 shield:SetCode(EFFECT_IMMUNE_EFFECT)
 shield:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_CLIENT_HINT)
 shield:SetTargetRange(LOCATION_ALL,0)
 shield:SetTarget(s.immfilter)
 shield:SetLabel(tp)
 shield:SetValue(function(e,re) return re:GetOwnerPlayer()~=e:GetLabel() and re:IsActiveType(TYPE_MONSTER|TYPE_TRAP) end)
 shield:SetReset(RESET_PHASE|PHASE_END)
 Duel.RegisterEffect(shield,tp)
end
function s.immfilter(e,c)
 return c:IsSetCard(SET_VEILSTRIKE) and c:IsOriginalType(TYPE_MONSTER)
  and (not c:IsLocation(LOCATION_REMOVED) or c:IsFaceup())
end
