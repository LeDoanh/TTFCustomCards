-- ============================================================
-- Card Name: <<CARD_NAME>>
-- Passcode : <<PASSCODE>>
-- Type     : Monster / Effect
-- Archetype: <<ARCHETYPE_NAME>> (0x<<SETCODE>>)
-- ============================================================
-- Effect 1: When your opponent activates a monster effect
--           (Quick Effect): You can discard this card;
--           negate the activation, and if you do, destroy it.
--           You can only use this effect of "<<CARD_NAME>>" once per turn.
-- ============================================================

local s,id=GetID()

function s.initial_effect(c)
    -- ============================================================
    -- Effect 1 — Quick Effect from hand: Negate opponent's monster
    -- ============================================================
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_QUICK_O)                        -- Quick Effect: can chain to opponent's effects
    e1:SetCode(EVENT_CHAINING)                             -- Fires when a chain link is activated
    e1:SetRange(LOCATION_HAND)                             -- Activates from hand
    e1:SetCountLimit(1,id)                                 -- Hard once per turn
    e1:SetCondition(s.handcon)                             -- Only opponent's monster effect
    e1:SetCost(s.handcost)                                 -- Cost: discard this card
    e1:SetTarget(s.handtg)
    e1:SetOperation(s.handop)
    c:RegisterEffect(e1)
end

-- ============================================================
-- Effect 1: Condition — Opponent activated a monster effect
-- ============================================================
function s.handcon(e,tp,eg,ep,ev,re,r,rp)
    return ep~=tp and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
end

-- ============================================================
-- Effect 1: Cost — Discard this card from hand to GY
-- ============================================================
function s.handcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:IsDiscardable() end
    Duel.SendtoGrave(c,REASON_DISCARD+REASON_COST)
end

-- ============================================================
-- Effect 1: Target — Always true (instant chain response)
-- ============================================================
function s.handtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
    if re:GetHandler():IsDestructable() then
        Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
    end
end

-- ============================================================
-- Effect 1: Operation — Negate the activation, then destroy
-- ============================================================
function s.handop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
        Duel.Destroy(eg,REASON_EFFECT)
    end
end
