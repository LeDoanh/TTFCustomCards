-- Gensokyo Scarlet - Remilia the Crimson Mist
-- ID: 777700015
local s,id=GetID()

local SET_GENSOKYO		 = 0xa70
local SET_GENSOKYO_SCARLET = 0xd7c
local CARD_REMILIA		 = 777700013 -- Gensokyo Scarlet - Remilia Scarlet

s.listed_series={SET_GENSOKYO,SET_GENSOKYO_SCARLET}
s.listed_names={CARD_REMILIA}

function s.initial_effect(c)
	-- Quy tắc Triệu hồi Dung hợp: "Gensokyo Scarlet - Remilia Scarlet" + 1+ quái thú "Gensokyo"
	c:EnableReviveLimit()
	Fusion.AddProcMixRep(c,true,true,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_GENSOKYO),1,99,CARD_REMILIA)

	-- Điều kiện Triệu hồi Đặc biệt: Phải được Triệu hồi Dung hợp trước, hoặc Triệu hồi Đặc biệt từ Extra Deck bằng cách xào nguyên liệu từ Mộ/trục xuất về Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)

	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetLabelObject(e1)
	e0:SetValue(s.splimit)
	c:RegisterEffect(e0)

	-- Hiệu ứng 1: Mỗi khi bài hoặc hiệu ứng của đối thủ giải quyết -> Đối thủ phải trả 400 LP, sau đó bạn hồi 200 LP
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVED)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.taxcon)
	e2:SetOperation(s.taxop)
	c:RegisterEffect(e2)

	-- Hiệu ứng 2 (Quick Effect): Nếu LP của bạn <= một nửa LP đối thủ -> Chia đôi LP đối thủ, sau đó hồi LP bằng một nửa số LP họ đã mất
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_RECOVER)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E+TIMING_MAIN_END+TIMING_END_PHASE)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.lpcon)
	e3:SetTarget(s.lptg)
	e3:SetOperation(s.lpop)
	c:RegisterEffect(e3)

	-- Hiệu ứng 3 (Dưới Mộ): Trả 800 LP -> Triệu hồi Đặc biệt lá bài này từ Mộ
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCountLimit(1,{id,1})
	e4:SetCost(s.gycost)
	e4:SetTarget(s.gytg)
	e4:SetOperation(s.gyop)
	c:RegisterEffect(e4)
end

--------------------------------------------------------------------------------
-- 1. LOGIC TRIỆU HỒI TỪ EXTRA DECK BẰNG CÁCH XÀO NGUYÊN LIỆU TỪ MỘ / TRỤC XUẤT
--------------------------------------------------------------------------------
function s.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA)
		or (st&SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION
		or se==e:GetLabelObject()
end

function s.matfilter(c)
	return c:IsSetCard(SET_GENSOKYO) and c:IsType(TYPE_MONSTER)
		and (not c:IsLocation(LOCATION_REMOVED) or c:IsFaceup())
		and c:IsAbleToDeckAsCost()
end

function s.rescon(sg,e,tp,mg)
	return #sg>=2 and sg:IsExists(Card.IsCode,1,nil,CARD_REMILIA)
end

function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	if Duel.GetLocationCountFromEx(tp,tp,nil,c)<=0 then return false end
	local g=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
	return aux.SelectUnselectGroup(g,e,tp,2,#g,s.rescon,0)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local g=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
	local sg=aux.SelectUnselectGroup(g,e,tp,2,#g,s.rescon,1,tp,HINTMSG_TODECK,s.rescon,nil,true)
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
	Duel.HintSelection(sg)
	Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_COST)
	sg:DeleteGroup()
end

--------------------------------------------------------------------------------
-- 2. LOGIC THU THUẾ LP MỖI KHI ĐỐI THỦ GIẢI QUYẾT BÀI / HIỆU ỨNG
--------------------------------------------------------------------------------
function s.taxcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp
end

function s.taxop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.CheckLPCost(1-tp,400) then
		Duel.Hint(HINT_CARD,0,id)
		Duel.PayLPCost(1-tp,400)
		Duel.Recover(tp,200,REASON_EFFECT)
	end
end

--------------------------------------------------------------------------------
-- 3. LOGIC CHIA ĐÔI LP ĐỐI THỦ & HỒI LP BẰNG MỘT NỬA LƯỢNG ĐỐI THỦ MẤT
--------------------------------------------------------------------------------
function s.lpcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetLP(tp)*2<=Duel.GetLP(1-tp)
end

function s.lptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLP(1-tp)>0 end
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,0)
end

function s.lpop(e,tp,eg,ep,ev,re,r,rp)
	local lp=Duel.GetLP(1-tp)
	if lp<=0 then return end
	Duel.SetLP(1-tp,(lp+1)//2)
	local lost=lp-Duel.GetLP(1-tp)
	if lost>0 then
		Duel.BreakEffect()
		Duel.Recover(tp,lost//2,REASON_EFFECT)
	end
end

--------------------------------------------------------------------------------
-- 4. LOGIC HỒI SINH TỪ MỘ BẰNG CÁCH TRẢ 800 LP
--------------------------------------------------------------------------------
function s.gycost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,800) end
	Duel.PayLPCost(tp,800)
end

function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end

function s.gyop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
