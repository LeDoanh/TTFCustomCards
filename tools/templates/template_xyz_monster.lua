-- ============================================================
-- Card Name: <<CARD_NAME>>
-- Passcode : <<PASSCODE>>
-- Type     : Monster / Xyz / Effect
-- Archetype: <<ARCHETYPE_NAME>> (0x<<SETCODE>>)
-- Materials: <<MATERIAL_COUNT>> Level <<RANK>> monsters
-- ============================================================
-- Effect 1: Once per turn: You can detach 1 material from this
--           card, then target 1 card on the field; destroy it.
-- ============================================================

local s,id=GetID()

function s.initial_effect(c)
    c:EnableReviveLimit()  -- Must be properly Xyz Summoned first

    -- ============================================================
    -- Summon Procedure — Generic Xyz with any materials
    -- ============================================================
    Xyz.AddProcedure(c,nil,<<RANK>>,<<MATERIAL_COUNT>>)

    -- ============================================================
    -- Effect 1 — Ignition: Detach to destroy a card on field
    -- ============================================================
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_IGNITION)                       -- Can only be activated during your Main Phase
    e1:SetRange(LOCATION_MZONE)                            -- Must be face-up on the Monster Zone
    e1:SetCountLimit(1)                                    -- Soft once per turn (each copy once)
    e1:SetCost(s.cost_detach)                              -- Cost: detach 1 Xyz material
    e1:SetTarget(s.tg_destroy)
    e1:SetOperation(s.op_destroy)
    c:RegisterEffect(e1)
end

-- ============================================================
-- Effect 1: Cost — Detach 1 Xyz material from this card
-- ============================================================
function s.cost_detach(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
    e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end

-- ============================================================
-- Effect 1: Filter — Any face-up destructible card
-- ============================================================
function s.filter_destroy(c)
    return c:IsFaceup() and c:IsDestructable()
end

-- ============================================================
-- Effect 1: Target — Select 1 card on the field to destroy
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
-- Effect 1: Operation — Destroy the targeted card
-- ============================================================
function s.op_destroy(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        Duel.Destroy(tc,REASON_EFFECT)
    end
end
