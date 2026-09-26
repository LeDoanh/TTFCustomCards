-- ============================================================
-- Card Name: <<CARD_NAME>>
-- Passcode : <<PASSCODE>>
-- Type     : Spell / Field
-- Archetype: <<ARCHETYPE_NAME>> (0x<<SETCODE>>)
-- ============================================================
-- Effect 1: When this card is activated: You can add 1
--           "<<ARCHETYPE_NAME>>" monster from your Deck to your hand.
--           You can only activate 1 "<<CARD_NAME>>" per turn.
-- Effect 2: All "<<ARCHETYPE_NAME>>" monsters you control
--           gain <<ATK_VALUE>> ATK.
-- Effect 3: Once per turn, during your Standby Phase:
--           Gain <<LP_AMOUNT>> LP.
-- ============================================================

local s,id=GetID()

function s.initial_effect(c)
    -- ============================================================
    -- Effect 1 — Activation: Search an archetype monster
    -- ============================================================
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
    e1:SetType(EFFECT_TYPE_ACTIVATE)                       -- Field Spell: activate from hand
    e1:SetCode(EVENT_FREE_CHAIN)                           -- No specific timing requirement
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)          -- Hard once per turn
    e1:SetTarget(s.tg_activate)
    e1:SetOperation(s.op_activate)
    c:RegisterEffect(e1)

    -- ============================================================
    -- Effect 2 — Continuous ATK boost for archetype monsters
    -- ============================================================
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)                          -- Affects other cards on the field
    e2:SetCode(EFFECT_UPDATE_ATTACK)                       -- Continuous ATK modification
    e2:SetRange(LOCATION_FZONE)                            -- Only while this card is face-up in Field Zone
    e2:SetTargetRange(LOCATION_MZONE,0)                    -- Affects your Monster Zones
    e2:SetTarget(s.tg_atkboost)
    e2:SetValue(<<ATK_VALUE>>)                             -- Amount of ATK to add
    c:RegisterEffect(e2)

    -- ============================================================
    -- Effect 3 — Mandatory Standby Phase trigger: Gain LP
    -- ============================================================
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_RECOVER)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)    -- Mandatory Trigger, responds to any field event
    e3:SetCode(EVENT_PHASE+PHASE_STANDBY)                  -- Fires during Standby Phase
    e3:SetRange(LOCATION_FZONE)                            -- Must be in the Field Zone
    e3:SetCountLimit(1)                                    -- Soft once per turn
    e3:SetTarget(s.tg_recover)
    e3:SetOperation(s.op_recover)
    c:RegisterEffect(e3)
end

-- ============================================================
-- Effect 1: Filter — Archetype monsters in Deck, able to add to hand
-- ============================================================
function s.filter_activate(c)
    return c:IsSetCard(0x<<SETCODE>>) and c:IsMonster() and c:IsAbleToHand()
end

-- ============================================================
-- Effect 1: Target — Check for valid search targets in Deck
-- ============================================================
function s.tg_activate(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.filter_activate,tp,LOCATION_DECK,0,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

-- ============================================================
-- Effect 1: Operation — Select 1 monster from Deck, add to hand
-- ============================================================
function s.op_activate(e,tp,eg,ep,ev,re,r,rp)
    if not e:GetHandler():IsRelateToEffect(e) then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.filter_activate,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end

-- ============================================================
-- Effect 2: Filter — Only archetype monsters you control
-- ============================================================
function s.tg_atkboost(e,c)
    return c:IsSetCard(0x<<SETCODE>>)
end

-- ============================================================
-- Effect 3: Target — Mandatory, always true
-- ============================================================
function s.tg_recover(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,<<LP_AMOUNT>>)
end

-- ============================================================
-- Effect 3: Operation — Gain LP
-- ============================================================
function s.op_recover(e,tp,eg,ep,ev,re,r,rp)
    if not e:GetHandler():IsRelateToEffect(e) then return end
    Duel.Recover(tp,<<LP_AMOUNT>>,REASON_EFFECT)
end
