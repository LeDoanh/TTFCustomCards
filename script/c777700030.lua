-- Gensokyo Nether - Hakugyokurou
-- ID: 777700030
local s,id=GetID()

local SET_GENSOKYO		= 0xa70
local SET_GENSOKYO_NETHER = 0xd6c

s.listed_series={SET_GENSOKYO,SET_GENSOKYO_NETHER}
s.listed_names={id}

function s.initial_effect(c)
	-- Kích hoạt Field Spell (HOPT kích hoạt lá bài)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e0)

	-- Hiệu ứng 1: Nếu lá bài này được kích hoạt -> Khóa Special Summon đến hết lượt này và lượt kế tiếp của bạn, trừ quái thú "Gensokyo"
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_CHAIN_SOLVED)
	e1:SetCondition(s.limcon)
	e1:SetOperation(s.limop)
	c:RegisterEffect(e1)

	-- Hiệu ứng 2: Trong Main Phase của bạn, quái thú "Gensokyo" không phải Synchro bạn điều khiển không thể bị đối thủ target bởi hiệu ứng bài
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCondition(s.tgcon)
	e2:SetTarget(s.tgtg)
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)

	-- Hiệu ứng 3: Mỗi khi 1 quái thú "Gensokyo Nether" được Triệu hồi trong lượt đối thủ
	-- -> Có thể Triệu hồi Đồng bộ 1 quái thú Đồng bộ "Gensokyo Nether"
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCondition(s.syncon)
	e3:SetTarget(s.syntg)
	e3:SetOperation(s.synop)
	c:RegisterEffect(e3)

	local e3b=e3:Clone()
	e3b:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3b)

	local e3c=e3:Clone()
	e3c:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e3c)

	-- Hiệu ứng 4 (Soft OPT): Gửi 1 lá từ tay xuống Mộ -> Search 1 lá "Gensokyo Nether" từ Deck lên tay
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1)
	e4:SetCost(s.thcost)
	e4:SetTarget(s.thtg)
	e4:SetOperation(s.thop)
	c:RegisterEffect(e4)
end

--------------------------------------------------------------------------------
-- 1. LOGIC KHÓA TRIỆU HỒI ĐẶC BIỆT ĐẾN HẾT LƯỢT NÀY & LƯỢT KẾ TIẾP CỦA BẠN
--------------------------------------------------------------------------------
function s.limcon(e,tp,eg,ep,ev,re,r,rp)
	return re and re:GetHandler()==e:GetHandler() and re:IsHasType(EFFECT_TYPE_ACTIVATE)
end

function s.limop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- Tính số lượt cần reset: 2 lượt nếu đang là lượt của bạn, 3 lượt nếu kích hoạt trong lượt đối thủ
	local rct=(Duel.GetTurnPlayer()==tp) and 2 or 3
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,3))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,rct)
	Duel.RegisterEffect(e1,tp)
end

function s.splimit(e,c)
	return not c:IsSetCard(SET_GENSOKYO)
end

--------------------------------------------------------------------------------
-- 2. LOGIC MIỄN NHIỄM TARGET CHO QUÁI NON-SYNCHRO "GENSOKYO" TRONG MAIN PHASE
--------------------------------------------------------------------------------
function s.tgcon(e)
	return Duel.GetTurnPlayer()==e:GetHandlerPlayer() and Duel.IsMainPhase()
end

function s.tgtg(e,c)
	return c:IsFaceup() and c:IsSetCard(SET_GENSOKYO) and not c:IsType(TYPE_SYNCHRO)
end

--------------------------------------------------------------------------------
-- 3. LOGIC SYNCHRO SUMMON KHI TRIỆU HỒI "GENSOKYO NETHER" TRONG LƯỢT ĐỐI THỦ
--------------------------------------------------------------------------------
function s.syncfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(SET_GENSOKYO_NETHER)
end

function s.syncon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==1-tp and eg:IsExists(s.syncfilter,1,nil,tp)
end

function s.synfilter(c)
	return c:IsSetCard(SET_GENSOKYO_NETHER) and c:IsSynchroSummonable(nil)
end

function s.syntg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.synfilter,tp,LOCATION_EXTRA,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function s.synop(e,tp,eg,ep,ev,re,r,rp)
	local syng=Duel.GetMatchingGroup(s.synfilter,tp,LOCATION_EXTRA,0,nil)
	if #syng>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sc=syng:Select(tp,1,1,nil):GetFirst()
		Duel.SynchroSummon(tp,sc,nil)
	end
end

--------------------------------------------------------------------------------
-- 4. LOGIC GỬI 1 LÁ TRÊN TAY XUỐNG MỘ -> SEARCH 1 LÁ "GENSOKYO NETHER"
--------------------------------------------------------------------------------
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,Card.IsAbleToGraveAsCost,1,1,REASON_COST)
end

function s.thfilter(c)
	return c:IsSetCard(SET_GENSOKYO_NETHER) and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end