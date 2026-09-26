-- ============================================================
-- Card Name: <<CARD_NAME>>
-- Passcode : <<PASSCODE>>
-- Type     : Monster / Link / Effect
-- Archetype: <<ARCHETYPE_NAME>> (0x<<SETCODE>>)
-- Materials: <<MIN_MATERIAL>>+ "<<ARCHETYPE_NAME>>" monsters
-- ============================================================
-- Effect 1: If this card is Link Summoned: You can add 1
--           "<<ARCHETYPE_NAME>>" card from your Deck to your hand.
--           You can only use this effect of "<<CARD_NAME>>" once per turn.
-- Effect 2: Monsters this card points to gain <<ATK_VALUE>> ATK.
-- ============================================================

local s,id=GetID()

function s.initial_effect(c)
    c:EnableReviveLimit()  -- Must be properly Link Summoned first

    -- ============================================================
    -- Summon Procedure — Link Summon using setcode materials
    -- ============================================================
    Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0x<<SETCODE>>),<<LINK_COUNT>>,<<MIN_MATERIAL>>)

    -- ============================================================
    -- Effect 1 — Trigger on Link Summon: Search an archetype card
    -- ============================================================
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)   -- Optional Trigger, responds to this card
    e1:SetProperty(EFFECT_FLAG_DELAY)                      -- "If" trigger: cannot miss the timing
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)                     -- Fires on any Special Summon
    e1:SetCountLimit(1,id)                                 -- Hard once per turn
    e1:SetCondition(s.spcon)                               -- Only when Link Summoned
    e1:SetTarget(s.tg_search)
    e1:SetOperation(s.op_search)
    c:RegisterEffect(e1)

    -- ============================================================
    -- Effect 2 — Continuous ATK boost for linked monsters
    -- ============================================================
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)                          -- Affects other cards on the field
    e2:SetCode(EFFECT_UPDATE_ATTACK)                       -- Continuous ATK modification
    e2:SetRange(LOCATION_MZONE)                            -- Only while this card is face-up on field
    e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)       -- Affects both players' Monster Zones
    e2:SetTarget(s.tg_linked)
    e2:SetValue(<<ATK_VALUE>>)                             -- Amount of ATK to add
    c:RegisterEffect(e2)
end

-- ============================================================
-- Effect 1: Condition — Must be Link Summoned (not revived etc.)
-- ============================================================
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
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
-- Effect 2: Filter — Only monsters this card points to
-- ============================================================
function s.tg_linked(e,c)
    return e:GetHandler():GetLinkedGroup():IsContains(c)
end
