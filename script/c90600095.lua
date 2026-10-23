-- Æthel Nemesis Cyber - Recharge
-- ID: 90600095
local s,id=GetID()
function s.initial_effect(c)
    -- Kích hoạt On-Field: Banish bài trên tay & Draw
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_REMOVE+CATEGORY_DRAW)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)

    -- Cho phép kích hoạt từ tay trong lượt đối thủ nếu điều khiển quái Æthel-Nemesis
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_QP_ACT_IN_NTPHAND)
    e2:SetCondition(s.handcon)
    c:RegisterEffect(e2)

    -- Hiệu ứng khi bị Banish: Lấy 1 lá archetype bị banish khác về tay hoặc gửi vào GY
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_TOHAND+CATEGORY_TOGRAVE)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
    e3:SetCode(EVENT_REMOVE)
    e3:SetCountLimit(1,id+100)
    e3:SetTarget(s.rmtg)
    e3:SetOperation(s.rmop)
    c:RegisterEffect(e3)
end

s.listed_series={0x115a, 0x115}

-- Condition: Kích hoạt từ tay trong lượt đối thủ
function s.handcon(e)
    return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,0x115a),e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end

-- Target & Activate H1: Banish hand & Draw
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    local hg=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
    if e:GetHandler():IsLocation(LOCATION_HAND) then
        hg:RemoveCard(e:GetHandler())
    end
    if chk==0 then return #hg>0 and Duel.IsPlayerCanDraw(tp,1) end
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_HAND)
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,1,tp,1)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local hg=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
    if #hg==0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local sg=hg:Select(tp,1,#hg,nil)
    local ct=Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
    if ct>0 then
        Duel.BreakEffect()
        Duel.Draw(tp,ct,REASON_EFFECT)
    end
end

-- Filter & Operation H2: Trigger khi bị Banish
function s.retfilter(c)
    return (c:IsSetCard(0x115a) or c:IsSetCard(0x115)) and not c:IsCode(id)
        and (c:IsAbleToHand() or c:IsAbleToGrave())
end

function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and s.retfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.retfilter,tp,LOCATION_REMOVED,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    local g=Duel.SelectTarget(tp,s.retfilter,tp,LOCATION_REMOVED,0,1,1,nil)
end

function s.rmop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        local b1=tc:IsAbleToHand()
        local b2=tc:IsAbleToGrave()
        if not (b1 or b2) then return end
        
        local op=0
        if b1 and b2 then
            op=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))
        elseif b1 then
            op=0
        else
            op=1
        end
        
        if op==0 then
            Duel.SendtoHand(tc,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,tc)
        else
            Duel.SendtoGrave(tc,REASON_EFFECT+REASON_RETURN)
        end
    end
end