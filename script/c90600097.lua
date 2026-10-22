-- Æthel Nemesis Area - Void Zone
-- ID: 90600097
local s,id=GetID()
local SETCODE_AETHEL_NEMESIS = 0x115A
function s.initial_effect(c)
    -- Khi kích hoạt: Add 1 Spell/Trap archetype từ Deck
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)

    -- Tăng ATK/DEF cho quái "Æthel-Nemesis" dựa trên số Spell bị banish
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_UPDATE_ATTACK)
    e2:SetRange(LOCATION_FZONE)
    e2:SetTargetRange(LOCATION_MZONE,0)
    e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x115a))
    e2:SetValue(s.val)
    c:RegisterEffect(e2)
    local e3=e2:Clone()
    e3:SetCode(EFFECT_UPDATE_DEFENSE)
    c:RegisterEffect(e3)

    -- Bảo kê: Trả 1 CARD bất kỳ bị banish về GY thay vì bị phá hủy
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e4:SetCode(EFFECT_DESTROY_REPLACE)
    e4:SetRange(LOCATION_FZONE)
    e4:SetTarget(s.reptg)
    e4:SetValue(s.repval)
    e4:SetOperation(s.repop)
    c:RegisterEffect(e4)

    -- Luân chuyển tài nguyên: Hoán đổi 1 lá ở GY và 1 lá ở Banish Zone
    local e5=Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id,2))
    e5:SetCategory(CATEGORY_TOGRAVE+CATEGORY_REMOVE)
    e5:SetType(EFFECT_TYPE_IGNITION)
    e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e5:SetRange(LOCATION_FZONE)
    e5:SetCountLimit(1,id)
    e5:SetTarget(s.swaptg)
    e5:SetOperation(s.swapop)
    c:RegisterEffect(e5)
end

s.listed_series={0x115a, 0x115}

-- Filter & Operation H1: Search Spell/Trap
function s.thfilter(c)
    return (c:IsSetCard(0x115a) or c:IsSetCard(0x115)) and c:IsSpellTrap() and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    if Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) 
        and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
        e:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
    end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    if Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) 
        and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
        if #g>0 then
            Duel.SendtoHand(g,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,g)
        end
    end
end

-- Value H2: ATK/DEF
function s.val(e,c)
    return Duel.GetMatchingGroupCount(Card.IsSpell,e:GetHandlerPlayer(),LOCATION_REMOVED,0,nil)*300
end

-- Filter & Operation H3: Protection (Replace Destruction bằng bất kỳ Banish Card nào)
function s.repfilter(c,tp)
    return c:IsFaceup() and c:IsControler(tp) and c:IsOnField()
        and (c:IsSetCard(0x115a) or c:IsSetCard(0x115))
        and c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
function s.togravefilter(c)
    return c:IsFaceup() -- Nhận mọi lá bài đang bị banish ngửa
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return eg:IsExists(s.repfilter,1,nil,tp)
        and Duel.IsExistingMatchingCard(s.togravefilter,tp,LOCATION_REMOVED,0,1,nil) end
    return Duel.SelectEffectYesNo(tp,c,aux.Stringid(id,1))
end
function s.repval(e,c)
    return s.repfilter(c,e:GetHandlerPlayer())
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.togravefilter,tp,LOCATION_REMOVED,0,1,1,nil)
    if #g>0 then
        Duel.SendtoGrave(g,REASON_EFFECT+REASON_REPLACE+REASON_RETURN)
    end
end

-- Filter & Operation H4: Swap GY & Banish
function s.swaptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return false end
    if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,LOCATION_GRAVE,0,1,nil)
        and Duel.IsExistingTarget(Card.IsAbleToGrave,tp,LOCATION_REMOVED,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g1=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,LOCATION_GRAVE,0,1,1,nil)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g2=Duel.SelectTarget(tp,Card.IsAbleToGrave,tp,LOCATION_REMOVED,0,1,1,nil)
    
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,g1,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g2,1,0,0)
end
function s.swapop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetTargetCards(e)
    if #g==2 then
        local tc_gy=g:Filter(Card.IsLocation,nil,LOCATION_GRAVE):GetFirst()
        local tc_rm=g:Filter(Card.IsLocation,nil,LOCATION_REMOVED):GetFirst()
        if tc_gy and tc_rm then
            Duel.Remove(tc_gy,POS_FACEUP,REASON_EFFECT)
            Duel.SendtoGrave(tc_rm,REASON_EFFECT+REASON_RETURN)
        end
    end
end