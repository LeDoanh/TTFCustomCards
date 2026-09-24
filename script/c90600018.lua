-- Sky Striker Ace - Aurelius Providence
-- ID: 2772337
local s,id=GetID()

function s.initial_effect(c)
    -- Link Summon: 2+ quái thú, bao gồm ít nhất 1 quái thú Link "Sky Striker"
    Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0x115),2,99,s.spcheck)
    c:EnableReviveLimit()

    -- Triệu hồi đặc biệt thay thế bằng cách gửi 1 Link "Sky Striker Ace" từ sân xuống Mộ khi có 10+ Phép trong Mộ
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_FIELD)
    e0:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e0:SetCode(EFFECT_SPSUMMON_PROC)
    e0:SetRange(LOCATION_EXTRA)
    e0:SetCondition(s.hspcon)
    e0:SetTarget(s.hsptg)
    e0:SetOperation(s.hspop)
    c:RegisterEffect(e0)

    -- Không bị ảnh hưởng bởi hiệu ứng của các lá bài khác
    local e0_imm=Effect.CreateEffect(c)
    e0_imm:SetType(EFFECT_TYPE_SINGLE)
    e0_imm:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e0_imm:SetRange(LOCATION_MZONE)
    e0_imm:SetCode(EFFECT_IMMUNE_EFFECT)
    e0_imm:SetValue(s.immval)
    c:RegisterEffect(e0_imm)

    -- HIỆU ỨNG 1 (Quick Effect): Trục xuất 1 Phép "Sky Striker" từ Deck hoặc Mộ; copy hiệu ứng
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCost(s.effcost)
    e1:SetTarget(s.efftg)
    e1:SetOperation(s.effop)
    c:RegisterEffect(e1)

    -- HIỆU ỨNG 2: Nếu có 3+ Phép trong Mộ: Đào 5 lá từ trên Deck, thêm 1 lá vào tay, phần còn lại gửi xuống Mộ
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetCondition(s.thcon)
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)

    -- HIỆU ỨNG 3 (Quick Effect): Gửi 1 lá "Sky Striker" từ sân xuống Mộ; trục xuất 20 lá, khóa kích hoạt hiệu ứng đối thủ
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetCategory(CATEGORY_REMOVE+CATEGORY_TOGRAVE)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1)
    e3:SetCost(s.lockcost)
    e3:SetTarget(s.locktg)
    e3:SetOperation(s.lockop)
    c:RegisterEffect(e3)
end

--------------------------------------------------------------------------------
-- LOGIC HỖ TRỢ & HIỆU ỨNG
--------------------------------------------------------------------------------

function s.spcheck(g,lc,tp)
    return g:IsExists(Card.IsSetCard,1,nil,0x115)
end

-- Triệu hồi đặc biệt từ Extra Deck
function s.hspfilter(c,tp)
    return c:IsSetCard(0x115) and c:IsType(TYPE_LINK) and c:IsFaceup() and c:IsAbleToGraveAsCost()
        and (Duel.GetLocationCountFromEx(tp,tp,c,TYPE_LINK)>0 or c:GetSequence()>=5)
end
function s.hspcon(e,c)
    if c==nil then return true end
    local tp=c:GetControler()
    local ct=Duel.GetMatchingGroupCount(function(tc) return tc:IsType(TYPE_SPELL) end,tp,LOCATION_GRAVE,0,nil)
    return ct>=10 and Duel.IsExistingMatchingCard(s.hspfilter,tp,LOCATION_MZONE,0,1,nil,tp)
end
function s.hsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
    local g=Duel.SelectMatchingCard(tp,s.hspfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
    if #g>0 then
        g:KeepAlive()
        e:SetLabelObject(g)
        return true
    end
    return false
end
function s.hspop(e,tp,eg,ep,ev,re,r,rp,c)
    local g=e:GetLabelObject()
    if g then
        Duel.SendtoGrave(g,REASON_COST)
        g:Delete()
    end
end

-- Miễn nhiễm
function s.immval(e,te)
    return te:GetOwner()~=e:GetHandler()
end

-- Hiệu ứng 1: Trục xuất 1 Phép Sky Striker để copy
function s.cfilter(c)
    return c:IsSetCard(0x115) and c:IsType(TYPE_SPELL) and c:IsAbleToRemoveAsCost()
end
function s.effcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
    Duel.Remove(g,POS_FACEUP,REASON_COST)
    e:SetLabelObject(g:GetFirst())
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
    local tc=e:GetLabelObject()
    if not tc then return end
    local te=tc:GetActivateEffect()
    if te then
        local op=te:GetOperation()
        if op then op(e,tp,eg,ep,ev,re,r,rp) end
    end
end

-- Hiệu ứng 2
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetMatchingGroupCount(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_SPELL)>=3
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=5 end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<5 then return end
    Duel.ConfirmDecktop(tp,5)
    local g=Duel.GetDecktopGroup(tp,5)
    if #g>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local sg=g:FilterSelect(tp,Card.IsAbleToHand,1,1,nil)
        if #sg>0 then
            Duel.SendtoHand(sg,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,sg)
            g:Sub(sg)
        end
        Duel.SendtoGrave(g,REASON_EFFECT+REASON_REVEAL)
    end
end

-- Hiệu ứng 3
function s.lockcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsSetCard,1,nil,0x115) 
        and Duel.GetMatchingGroupCount(Card.IsAbleToRemove,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,0,nil)>=20 end
    local rg=Duel.SelectReleaseGroup(tp,Card.IsSetCard,1,1,nil,0x115)
    Duel.SendtoGrave(rg,REASON_COST+REASON_RELEASE)
    local sg=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,0,20,20,nil)
    Duel.Remove(sg,POS_FACEDOWN,REASON_COST)
end
function s.locktg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
end
function s.lockop(e,tp,eg,ep,ev,re,r,rp)
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetCode(EFFECT_CANNOT_ACTIVATE)
    e1:SetTargetRange(0,1)
    e1:SetValue(1)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
end