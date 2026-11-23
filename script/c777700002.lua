-- Gensokyo Ordinary Magician - Marisa Kirisame
-- ID: 777700002
local s,id=GetID()

local SET_GENSOKYO = 0xa70

s.listed_series={SET_GENSOKYO}
s.listed_names={id}

function s.initial_effect(c)
	-- Hiệu ứng 1: Triệu hồi Đặc biệt từ tay (gửi 1 lá "Gensokyo" hoặc 2 Spell khác tên từ tay/sân xuống Mộ)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	e1:SetValue(1) -- Đánh dấu được triệu hồi bằng chính cách này
	c:RegisterEffect(e1)

	-- Hiệu ứng 2: Nếu được Triệu hồi bằng cách trên -> Search 1 quái "Gensokyo" khác tên
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.th1con)
	e2:SetTarget(s.th1tg)
	e2:SetOperation(s.th1op)
	c:RegisterEffect(e2)

	-- Hiệu ứng 3a: Làm nguyên liệu Triệu hồi cho quái "Gensokyo" -> Lấy 1 Spell/Trap "Gensokyo" từ Deck hoặc Mộ
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetCountLimit(1,{id,2})
	e3:SetCondition(s.matcon)
	e3:SetTarget(s.th2tg)
	e3:SetOperation(s.th2op)
	c:RegisterEffect(e3)

	-- Hiệu ứng 3b: Bị Hiến tế (Tribute) để Triệu hồi quái "Gensokyo" -> Lấy 1 Spell/Trap "Gensokyo" từ Deck hoặc Mộ
	local e4=e3:Clone()
	e4:SetCode(EVENT_RELEASE)
	e4:SetCondition(s.relcon)
	c:RegisterEffect(e4)
end

--------------------------------------------------------------------------------
-- 1. LOGIC TRIỆU HỒI ĐẶC BIỆT TỪ TAY
--------------------------------------------------------------------------------
function s.spfilter(c)
	return (c:IsSetCard(SET_GENSOKYO) or c:IsType(TYPE_SPELL)) and c:IsAbleToGraveAsCost()
end

function s.rescon(sg,e,tp,mg)
	if Duel.GetMZoneCount(tp,sg)<=0 then return false end
	if #sg==1 then
		return sg:GetFirst():IsSetCard(SET_GENSOKYO)
	elseif #sg==2 then
		return sg:FilterCount(Card.IsType,nil,TYPE_SPELL)==2 and sg:GetClassCount(Card.GetCode)==2
	end
	return false
end

function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,c)
	return aux.SelectUnselectGroup(g,e,tp,1,2,s.rescon,0)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,c)
	local sg=aux.SelectUnselectGroup(g,e,tp,1,2,s.rescon,1,tp,HINTMSG_TOGRAVE,nil,nil,true)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	end
	return false
end

function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local sg=e:GetLabelObject()
	if not sg then return end
	Duel.SendtoGrave(sg,REASON_COST)
	sg:DeleteGroup()
end

--------------------------------------------------------------------------------
-- 2. LOGIC SEARCH QUÁI "GENSOKYO" KHI TRIỆU HỒI BẰNG HIỆU ỨNG 1
--------------------------------------------------------------------------------
function s.th1con(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL+1)
end

function s.th1filter(c)
	return c:IsSetCard(SET_GENSOKYO) and c:IsType(TYPE_MONSTER) and not c:IsCode(id) and c:IsAbleToHand()
end

function s.th1tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.th1filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.th1op(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.th1filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

--------------------------------------------------------------------------------
-- 3. LOGIC LẤY SPELL/TRAP KHI LÀM NGUYÊN LIỆU HOẶC HIẾN TẾ
--------------------------------------------------------------------------------
function s.matcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	return rc and rc:IsSetCard(SET_GENSOKYO)
		and (r&(REASON_FUSION+REASON_SYNCHRO+REASON_XYZ+REASON_LINK))~=0
end

function s.relcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	return rc and rc:IsSetCard(SET_GENSOKYO)
		and (c:IsReason(REASON_SUMMON) or c:IsReason(REASON_RITUAL) or (c:IsReason(REASON_COST) and rc:IsSummonType(SUMMON_TYPE_SPECIAL)))
end

function s.th2filter(c)
	return c:IsSetCard(SET_GENSOKYO) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end

function s.th2tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.th2filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end

function s.th2op(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.th2filter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
