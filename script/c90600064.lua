-- Sky Striker Special Mobilize - The End of Era
-- ID: 90600064
local s,id=GetID()
function s.initial_effect(c)
    -- Hiệu ứng 1 (Kích hoạt trên sân): Tag-out Sky Striker Link Monster + Gửi 1 card đối thủ xuống GY nếu >=3 Spells
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.condition)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)

    -- Hiệu ứng 2 (Dưới GY): Banish từ GY để add hoặc Special Summon 1 "Sky Striker" monster bị banish
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,id)
    e2:SetCondition(aux.exccon)
    e2:SetCost(aux.bfgcost)
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)
end

s.listed_series={0x115} -- Sky Striker archetype code

-- Điều kiện chuẩn xác: Không có quái thú nào nằm ở Main Monster Zone của bạn
function s.condition(e,tp,eg,ep,ev,re,r,rp)
    return not Duel.IsExistingMatchingCard(Card.IsLocation,tp,LOCATION_MZONE,0,1,nil,LOCATION_MZONE)
end

-- Lọc "Sky Striker Ace" Link Monster trên sân để banish
function s.tgfilter(c,e,tp)
    return c:IsFaceup() and c:IsSetCard(0x115) and c:IsType(TYPE_LINK)
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c)
end

-- Lọc quái thú Extra Deck có tên và Attribute khác
function s.spfilter(c,e,tp,tc)
    return c:IsSetCard(0x115) and c:IsType(TYPE_LINK) and not c:IsCode(tc:GetCode()) and not c:IsAttribute(tc:GetAttribute())
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
        and Duel.GetLocationCountFromEx(tp,tp,tc,c)>0
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.tgfilter(chkc,e,tp) end
    if chk==0 then 
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) 
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)~=0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc)
        local sc=sg:GetFirst()
        if sc and Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)>0 then
            -- Kiểm tra nếu có từ 3 Spells trở lên trong GY thì gửi 1 card đối thủ xuống GY
            if Duel.GetMatchingGroupCount(Card.IsSpell,tp,LOCATION_GRAVE,0,nil)>=3 
                and Duel.IsExistingMatchingCard(nil,tp,0,LOCATION_ONFIELD,1,nil) 
                and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
                Duel.BreakEffect()
                Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
                local dg=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
                if #dg>0 then
                    Duel.SendtoGrave(dg,REASON_EFFECT)
                end
            end
        end
    end
end

-- Filter cho hiệu ứng dưới GY (Banish zone -> Add to hand hoặc Special Summon)
function s.rmfilter(c,e,tp)
    return c:IsSetCard(0x115) and c:IsMonster() and c:IsFaceup()
        and (c:IsAbleToHand() or c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and s.rmfilter(chkc,e,tp) end
    if chk==0 then return Duel.IsExistingTarget(s.rmfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    local g=Duel.SelectTarget(tp,s.rmfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
    Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local tag_card=Duel.GetFirstTarget()
    if tag_card and tag_card:IsRelateToEffect(e) then
        local b1=tag_card:IsAbleToHand()
        local b2=tag_card:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        local op=0
        if b1 and b2 then
            op=Duel.SelectOption(tp,aux.Stringid(id,3),aux.Stringid(id,4))
        elseif b1 then
            op=0
        elseif b2 then
            op=1
        else
            return
        end
        if op==0 then
            Duel.SendtoHand(tag_card,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,tag_card)
        else
            Duel.SpecialSummon(tag_card,0,tp,tp,false,false,POS_FACEUP)
        end
    end
end