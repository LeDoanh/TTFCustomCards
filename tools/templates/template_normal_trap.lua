-- ============================================================
-- Card Name: <<CARD_NAME>>
-- Passcode : <<PASSCODE>>
-- Type     : Trap / Normal
-- Archetype: <<ARCHETYPE_NAME>> (0x<<SETCODE>>)
-- ============================================================
-- Effect 1: When your opponent Normal Summons a monster from
--           the hand: Destroy that monster.
--           You can only activate 1 "<<CARD_NAME>>" per turn.
-- ============================================================

local s,id=GetID()

function s.initial_effect(c)
    -- ============================================================
    -- Effect 1 — Respond to opponent's Normal Summon, destroy it
    -- ============================================================
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_ACTIVATE)                       -- Normal Trap: set first, then activate later
    e1:SetCode(EVENT_SUMMON_SUCCESS)                       -- Triggers on any Normal Summon
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)          -- Hard once per turn
    e1:SetCondition(s.condition)                           -- Only opponent's summon from hand
    e1:SetTarget(s.tg_destroy)
    e1:SetOperation(s.op_destroy)
    c:RegisterEffect(e1)
end

-- ============================================================
-- Effect 1: Condition — Only respond to opponent's hand summon
-- ============================================================
function s.condition(e,tp,eg,ep,ev,re,r,rp)
    return ep~=tp and eg:IsExists(Card.IsSummonLocation,1,nil,LOCATION_HAND)
end

-- ============================================================
-- Effect 1: Filter — Face-up, destructible cards
-- ============================================================
function s.filter_destroy(c)
    return c:IsFaceup() and c:IsDestructable()
end

-- ============================================================
-- Effect 1: Target — Use the summoned monster(s) from the event
-- ============================================================
function s.tg_destroy(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=eg:Filter(s.filter_destroy,nil)
    if chk==0 then return #g>0 end
    Duel.SetTargetCard(g)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end

-- ============================================================
-- Effect 1: Operation — Destroy the targeted summoned monsters
-- ============================================================
function s.op_destroy(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetTargetCards(e)
    if #g>0 then
        Duel.Destroy(g,REASON_EFFECT)
    end
end
