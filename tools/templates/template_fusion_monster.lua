-- ============================================================
-- Card Name: <<CARD_NAME>>
-- Passcode : <<PASSCODE>>
-- Type     : Monster / Fusion / Effect
-- Archetype: <<ARCHETYPE_NAME>> (0x<<SETCODE>>)
-- Materials: 2+ "<<ARCHETYPE_NAME>>" monsters
-- ============================================================
-- Effect 1: If this card is Fusion Summoned: You can target
--           1 card your opponent controls; destroy it.
--           You can only use this effect of "<<CARD_NAME>>" once per turn.
-- ============================================================

local s,id=GetID()

function s.initial_effect(c)
    c:EnableReviveLimit()  -- Must be properly Fusion Summoned first

    -- ============================================================
    -- Summon Procedure — Fusion Summon using <<MIN_MATERIAL>> setcode materials
    -- ============================================================
    Fusion.AddProcFunRep(c,s.mfilter,<<MIN_MATERIAL>>,false)

    -- ============================================================
    -- Effect 1 — Trigger on Fusion Summon: Destroy opponent's card
    -- ============================================================
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)   -- Optional Trigger, responds to this card
    e1:SetProperty(EFFECT_FLAG_DELAY)                      -- "If" trigger: cannot miss the timing
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)                     -- Fires when this card is Special Summoned
    e1:SetCountLimit(1,id)                                 -- Hard once per turn
    e1:SetCondition(s.spcon)                               -- Only when Fusion Summoned
    e1:SetTarget(s.tg_destroy)
    e1:SetOperation(s.op_destroy)
    c:RegisterEffect(e1)
end

-- ============================================================
-- Fusion Material filter — Cards that can be used as material
-- ============================================================
function s.mfilter(c,fc,sumtype,tp)
    return c:IsSetCard(0x<<SETCODE>>,fc,sumtype,tp)
end

-- ============================================================
-- Effect 1: Condition — Must be Fusion Summoned (not revived etc.)
-- ============================================================
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end

-- ============================================================
-- Effect 1: Filter — Valid destroy targets on opponent's field
-- ============================================================
function s.filter_destroy(c)
    return c:IsFaceup() and c:IsDestructable()
end

-- ============================================================
-- Effect 1: Target — Select 1 of opponent's cards to destroy
-- ============================================================
function s.tg_destroy(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and s.filter_destroy(chkc) end
    if chk==0 then
        return Duel.IsExistingTarget(s.filter_destroy,tp,0,LOCATION_ONFIELD,1,nil)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectTarget(tp,s.filter_destroy,tp,0,LOCATION_ONFIELD,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end

-- ============================================================
-- Effect 1: Operation — Destroy the targeted card
-- ============================================================
function s.op_destroy(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        Duel.Destroy(tc,REASON_EFFECT)
    end
end
