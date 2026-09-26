-- ============================================================
-- Card Name: <<CARD_NAME>>
-- Passcode : <<PASSCODE>>
-- Type     : Monster / Effect
-- Archetype: <<ARCHETYPE_NAME>> (0x<<SETCODE>>)
-- ============================================================
-- Effect 1: If this card is Normal Summoned: You can add
--           1 "<<ARCHETYPE_NAME>>" card from your Deck to your hand.
--           You can only use this effect of "<<CARD_NAME>>" once per turn.
-- Effect 2: Once per turn: You can target 1 face-up card
--           on the field; destroy it.
-- ============================================================

local s,id=GetID()

function s.initial_effect(c)
    -- ============================================================
    -- Effect 1 — Trigger on Normal Summon: Search an archetype card
    -- ============================================================
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)  -- Optional Trigger, responds to this card only
    e1:SetProperty(EFFECT_FLAG_DELAY)                      -- "If" trigger: cannot miss the timing
    e1:SetCode(EVENT_SUMMON_SUCCESS)                       -- Fires when this card is Normal Summoned
    e1:SetCountLimit(1,id)                                 -- Hard once per turn (shared among copies)
    e1:SetTarget(s.tg_search)
    e1:SetOperation(s.op_search)
    c:RegisterEffect(e1)

    -- ============================================================
    -- Effect 2 — Ignition: Target 1 face-up card and destroy it
    -- ============================================================
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_IGNITION)                       -- Can only be activated during your Main Phase
    e2:SetRange(LOCATION_MZONE)                            -- Must be face-up on the Monster Zone
    e2:SetCountLimit(1)                                    -- Soft once per turn (each copy once)
    e2:SetTarget(s.tg_destroy)
    e2:SetOperation(s.op_destroy)
    c:RegisterEffect(e2)
end

-- ============================================================
-- Effect 1: Filter — Valid search targets in Deck
-- ============================================================
function s.filter_search(c)
    return c:IsSetCard(0x<<SETCODE>>) and c:IsAbleToHand()
end

-- ============================================================
-- Effect 1: Target — Check if a valid search target exists
-- ============================================================
function s.tg_search(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.filter_search,tp,LOCATION_DECK,0,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

-- ============================================================
-- Effect 1: Operation — Select 1 card from Deck, add to hand
-- ============================================================
function s.op_search(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.filter_search,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end

-- ============================================================
-- Effect 2: Filter — Valid destroy targets (face-up, destructible)
-- ============================================================
function s.filter_destroy(c)
    return c:IsFaceup() and c:IsDestructable()
end

-- ============================================================
-- Effect 2: Target — Select 1 face-up card to destroy
-- ============================================================
function s.tg_destroy(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsOnField() and s.filter_destroy(chkc) end
    if chk==0 then
        return Duel.IsExistingTarget(s.filter_destroy,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectTarget(tp,s.filter_destroy,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end

-- ============================================================
-- Effect 2: Operation — Destroy the targeted card
-- ============================================================
function s.op_destroy(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then  -- Guard: target must still be valid
        Duel.Destroy(tc,REASON_EFFECT)
    end
end
