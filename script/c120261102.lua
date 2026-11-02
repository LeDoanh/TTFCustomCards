--Veilstrike Protect!
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
 e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
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

function s.thfilter(c)
 return c:IsSetCard(SET_VEILSTRIKE) and c:IsTrap() and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
 if chk==0 then return true end
 e:SetLabel(s.fromhand(e))
 if e:GetLabel()==1 then Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK) end
end
function s.activate(e,tp)
 local shield=Effect.CreateEffect(e:GetHandler())
 shield:SetDescription(aux.Stringid(id,4))
 shield:SetType(EFFECT_TYPE_FIELD)
 shield:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
 shield:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_CLIENT_HINT)
 shield:SetTargetRange(LOCATION_ONFIELD,0)
 --Without SetCountLimit, the core tracks this count separately for each card.
 shield:SetValue(function(e,re,r,rp) return (r&(REASON_BATTLE|REASON_EFFECT))~=0 and 1 or 0 end)
 shield:SetReset(RESET_PHASE|PHASE_END)
 Duel.RegisterEffect(shield,tp)
 if e:GetLabel()~=1 or not Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
  or not Duel.SelectYesNo(tp,aux.Stringid(id,3)) then return end
 Duel.BreakEffect()
 Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
 local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
 if #g>0 then Duel.SendtoHand(g,nil,REASON_EFFECT) Duel.ConfirmCards(1-tp,g) end
end
