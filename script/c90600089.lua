-- Æthel Nemesis Sovereign - Abyssal Emperor
-- ID: 90600089
local s,id=GetID()
function s.initial_effect(c)
    -- Điều kiện Link Summon: 2+ quái thú, bao gồm 1 "Æthel Nemesis" hoặc "Sky Striker"
    c:EnableReviveLimit()
    Link.AddProcedure(c, nil, 2, 99, s.lcheck)

    -- Must be Link Summoned
    local e0=Effect.CreateEffect(c)
    e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetCode(EFFECT_SPSUMMON_CONDITION)
    e0:SetValue(s.splimit)
    c:RegisterEffect(e0)

    -- Hiệu ứng 1: Khi Special Summon -> banish 1 "Æthel Nemesis" Spell từ Deck/GY, gửi 1 lá của đối thủ vào GY
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_REMOVE+CATEGORY_TOGRAVE)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- Hiệu ứng 2: Quick Effect trong Main Phase -> banish 1 lá ở GY/trên sân đối thủ; banish 1 lá "Æthel Nemesis" hoặc "Sky Striker" ở GY mình
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_REMOVE)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E+TIMING_MAIN_END)
    e2:SetCountLimit(1,id+100)
    e2:SetCondition(s.rmcon)
    e2:SetTarget(s.rmtg)
    e2:SetOperation(s.rmop)
    c:RegisterEffect(e2)
end

-- Mã Archetype (0x115a: Æthel-Nemesis, 0x115: Sky Striker)
s.listed_series={0x115a, 0x115}

-- Điều kiện triệu hồi độc quyền từ Extra Deck bằng Link Summon
function s.splimit(e,se,sp,st)
    return (st&SUMMON_TYPE_LINK)==SUMMON_TYPE_LINK
end

-- Kiểm tra nguyên liệu Link
function s.lcheck(g,lc,sumtype,tp)
    return g:IsExists(s.matfilter,1,nil,lc,sumtype,tp)
end
function s.matfilter(c,lc,sumtype,tp)
    return c:IsSetCard(0x115a,lc,sumtype,tp) or c:IsSetCard(0x115,lc,sumtype,tp)
end

-- Filter Spell cho H1
function s.spcostfilter(c)
    return c:IsSetCard(0x115a) and c:IsSpell() and c:IsAbleToRemove()
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then 
        return Duel.IsExistingMatchingCard(s.spcostfilter,tp,LOCATION_DECK+LOCATION_GY,0,1,nil)
            and Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,0,LOCATION_ONFIELD,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK+LOCATION_GY)
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,1-tp,LOCATION_ONFIELD)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,s.spcostfilter,tp,LOCATION_DECK+LOCATION_GY,0,1,1,nil)
    if #g>0 and Duel.Remove(g,POS_FACEUP,REASON_EFFECT)>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
        local tg=Duel.SelectMatchingCard(tp,Card.IsAbleToGrave,tp,0,LOCATION_ONFIELD,1,1,nil)
        if #tg>0 then
            Duel.SendtoGrave(tg,REASON_EFFECT)
        end
    end
end

-- Condition, Target & Operation cho H2
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsMainPhase()
end
function s.opprmfilter(c)
    return c:IsAbleToRemove() and (c:IsLocation(LOCATION_GY) or c:IsFaceup())
end
function s.myrmfilter(c)
    return (c:IsSetCard(0x115a) or c:IsSetCard(0x115)) and c:IsAbleToRemove()
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.opprmfilter,tp,0,LOCATION_ONFIELD+LOCATION_GY,1,nil)
            and Duel.IsExistingMatchingCard(s.myrmfilter,tp,LOCATION_GY,0,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_ONFIELD+LOCATION_GY)
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_GY)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g1=Duel.SelectMatchingCard(tp,s.opprmfilter,tp,0,LOCATION_ONFIELD+LOCATION_GY,1,1,nil)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g2=Duel.SelectMatchingCard(tp,s.myrmfilter,tp,LOCATION_GY,0,1,1,nil)
    if #g1>0 and #g2>0 then
        g1:Merge(g2)
        Duel.Remove(g1,POS_FACEUP,REASON_EFFECT)
    end
end