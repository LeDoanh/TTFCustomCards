-- ============================================================
-- Card Name: <<CARD_NAME>>
-- Passcode : <<PASSCODE>>
-- Type     : Monster / Pendulum / Effect
-- Archetype: <<ARCHETYPE_NAME>> (0x<<SETCODE>>)
-- ============================================================
-- Pendulum Effect:
--   Once per turn: You can target 1 card on the field; destroy it.
-- Monster Effect:
--   If this card is Pendulum Summoned: You can add 1
--   "<<ARCHETYPE_NAME>>" Pendulum Monster from your Deck to your hand.
--   You can only use this effect of "<<CARD_NAME>>" once per turn.
-- ============================================================

local s,id=GetID()

function s.initial_effect(c)
    -- ============================================================
    -- Summon Procedure — Enable Pendulum Summon
    -- ============================================================
    Pendulum.AddProcedure(c)

    -- ============================================================
    -- Pendulum Effect — Ignition in Pendulum Zone: Destroy a card
    -- ============================================================
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_IGNITION)                       -- Can only activate during your Main Phase
    e1:SetRange(LOCATION_PZONE)                            -- Only while this card is in a Pendulum Zone
    e1:SetCountLimit(1)                                    -- Soft once per turn (each copy once)
    e1:SetCondition(s.pencon)                              -- Optional: extra condition
    e1:SetCost(s.pencost)                                  -- Optional: cost to pay
    e1:SetTarget(s.pentg_destroy)
    e1:SetOperation(s.penop_destroy)
    c:RegisterEffect(e1)

    -- ============================================================
    -- Monster Effect — Trigger on Pendulum Summon: Search
    -- ============================================================
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)   -- Optional Trigger, responds to this card
    e2:SetProperty(EFFECT_FLAG_DELAY)                      -- "If" trigger: cannot miss the timing
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)                     -- Fires when this card is Special Summoned
    e2:SetCountLimit(1,id)                                 -- Hard once per turn
    e2:SetCondition(s.monspcon)                            -- Only when Pendulum Summoned
    e2:SetTarget(s.montg_search)
    e2:SetOperation(s.monop_search)
    c:RegisterEffect(e2)
end

-- ============================================================
-- Pendulum Effect: Condition — e.g. "if you control no monsters"
-- ============================================================
function s.pencon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end

-- ============================================================
-- Pendulum Effect: Cost — e.g. destroy another card you control
-- ============================================================
function s.pencost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end  -- No cost in this template (placeholder)
end

-- ============================================================
-- Pendulum Effect: Filter — Any face-up destructible card
-- ============================================================
function s.filter_pen_destroy(c)
    return c:IsFaceup() and c:IsDestructable()
end

-- ============================================================
-- Pendulum Effect: Target — Select 1 card on the field to destroy
-- ============================================================
function s.pentg_destroy(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsOnField() and s.filter_pen_destroy(chkc) end
    if chk==0 then
        return Duel.IsExistingTarget(s.filter_pen_destroy,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectTarget(tp,s.filter_pen_destroy,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end

-- ============================================================
-- Pendulum Effect: Operation — Destroy the targeted card
-- ============================================================
function s.penop_destroy(e,tp,eg,ep,ev,re,r,rp)
    if not e:GetHandler():IsRelateToEffect(e) then return end
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        Duel.Destroy(tc,REASON_EFFECT)
    end
end

-- ============================================================
-- Monster Effect: Condition — Must be Pendulum Summoned
-- ============================================================
function s.monspcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_PENDULUM)
end

-- ============================================================
-- Monster Effect: Filter — Archetype Pendulum Monsters in Deck
-- ============================================================
function s.filter_mon_search(c)
    return c:IsSetCard(0x<<SETCODE>>) and c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()
end

-- ============================================================
-- Monster Effect: Target — Check for valid search targets
-- ============================================================
function s.montg_search(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.filter_mon_search,tp,LOCATION_DECK,0,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

-- ============================================================
-- Monster Effect: Operation — Select and add to hand
-- ============================================================
function s.monop_search(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.filter_mon_search,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end
