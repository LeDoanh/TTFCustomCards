-- Æthel Nemesis Network - Gatekeeper
-- ID: 90600087
local s,id=GetID()
local SETCODE_AETHEL_NEMESIS = 0x115A
function s.initial_effect(c)
    -- Điều kiện Link Summon: 2 quái thú, bao gồm 1 "Æthel-Nemesis" hoặc "Sky Striker"
    c:EnableReviveLimit()
    Link.AddProcedure(c, s.matfilter, 1, 1, s.lcheck)
    
    -- Hiệu ứng 1: Khi Special Summon -> Banish 1 quái thú Æthel-Nemesis hoặc Sky Striker từ Deck
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_REMOVE)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.rmtg)
    e1:SetOperation(s.rmop)
    c:RegisterEffect(e1)

    -- Hiệu ứng 2: Quick Effect trong Main Phase đối thủ -> Banish 1 card ở GY đối thủ & dùng làm toàn bộ nguyên liệu Link
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_REMOVE)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetRange(LOCATION_MZONE)
    e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
    e2:SetCountLimit(1,id+100)
    e2:SetCondition(s.linkcond)
    e2:SetTarget(s.linktg)
    e2:SetOperation(s.linkop)
    c:RegisterEffect(e2)
end

-- Mã Archetype (0x115a: Æthel-Nemesis, 0x115: Sky Striker)
s.listed_series={0x115a, 0x115}

function s.matfilter(c,lc,sumtype,tp)
    return c:IsSetCard(0x115a,lc,sumtype,tp) or c:IsSetCard(0x115,lc,sumtype,tp)
end

function s.lcheck(g,lc,sumtype,tp)
    return g:GetCount()==2
end

-- Filter & xử lý Hiệu ứng 1
function s.rmfilter(c)
    return c:IsMonster() and (c:IsSetCard(0x115a) or c:IsSetCard(0x115)) and c:IsAbleToRemove()
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,s.rmfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
    end
end

-- Filter & xử lý Hiệu ứng 2
function s.linkcond(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsMainPhase() and Duel.GetTurnPlayer()~=tp
end
function s.linktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_GY) and chkc:IsControler(1-tp) and chkc:IsAbleToRemove() end
    if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_GY,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_GY,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
function s.linkop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)>0 then
        if c:IsRelateToEffect(e) and c:IsFaceup() then
            -- Cho phép lá bài này làm toàn bộ nguyên liệu Link Summon cho 1 quái thú Æthel-Nemesis trong lượt này
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_LINK_MATERIAL_COUNT)
            e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
            e1:SetValue(s.matval)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
            c:RegisterEffect(e1)
        end
    end
end
function s.matval(e,lc)
    if lc:IsSetCard(0x115a) then
        return lc:GetLink()
    end
    return 0
end