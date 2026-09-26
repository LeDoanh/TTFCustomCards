-- ============================================================
-- Card Name: <<CARD_NAME>>
-- Passcode : <<PASSCODE>>
-- Type     : Monster / Synchro / Effect
-- Archetype: <<ARCHETYPE_NAME>> (0x<<SETCODE>>)
-- ============================================================
-- Effect 1: If this card is Synchro Summoned: You can Special
--           Summon 1 Level 4 or lower monster from your GY.
--           You can only use this effect of "<<CARD_NAME>>" once per turn.
-- Effect 2: All "<<ARCHETYPE_NAME>>" monsters you control
--           (except this card) gain <<ATK_VALUE>> ATK.
-- ============================================================

local s,id=GetID()

function s.initial_effect(c)
    -- Enable revive limit
    c:EnableReviveLimit()

    -- ============================================================
    -- Summon Procedure — Generic Synchro (Tuner + 1+ non-Tuners)
    -- ============================================================
    Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(nil),1,99)

    -- ============================================================
    -- Effect 1 — Trigger on Synchro Summon: Revive a low-level monster
    -- ============================================================
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)   -- Optional Trigger, responds to this card
    e1:SetProperty(EFFECT_FLAG_DELAY)                      -- "If" trigger: cannot miss the timing
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)                     -- Fires on any Special Summon
    e1:SetCountLimit(1,id)                                 -- Hard once per turn
    e1:SetCondition(s.spcon)                               -- Only when Synchro Summoned
    e1:SetTarget(s.tg_revive)
    e1:SetOperation(s.op_revive)
    c:RegisterEffect(e1)

    -- ============================================================
    -- Effect 2 — Continuous ATK boost for archetype monsters
    -- ============================================================
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)                          -- Affects other cards on the field
    e2:SetCode(EFFECT_UPDATE_ATTACK)                       -- Continuous ATK modification
    e2:SetRange(LOCATION_MZONE)                            -- Only while this card is face-up on field
    e2:SetTargetRange(LOCATION_MZONE,0)                    -- Affects your Monster Zones
    e2:SetTarget(s.tg_atkboost)
    e2:SetValue(<<ATK_VALUE>>)                             -- Amount of ATK to add
    c:RegisterEffect(e2)
end

-- ============================================================
-- Effect 1: Condition — Must be Synchro Summoned (not revived etc.)
-- ============================================================
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end

-- ============================================================
-- Effect 1: Filter — Level 4 or lower monsters that can be SS'd
-- ============================================================
function s.filter_revive(c,e,tp)
    return c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

-- ============================================================
-- Effect 1: Target — Check GY for valid revival targets + zone space
-- ============================================================
function s.tg_revive(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and Duel.IsExistingMatchingCard(s.filter_revive,tp,LOCATION_GRAVE,0,1,nil,e,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end

-- ============================================================
-- Effect 1: Operation — Select and Special Summon a monster from GY
-- ============================================================
function s.op_revive(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.filter_revive,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
    end
end

-- ============================================================
-- Effect 2: Filter — Archetype monsters except this card itself
-- ============================================================
function s.tg_atkboost(e,c)
    return c:IsSetCard(0x<<SETCODE>>) and c~=e:GetHandler()
end
