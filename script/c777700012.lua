-- Gensokyo Scarlet - Koakuma
-- ID: 777700012
local s,id=GetID()

local SET_GENSOKYO		 = 0xa70
local SET_GENSOKYO_SCARLET = 0xd7c

s.listed_series={SET_GENSOKYO,SET_GENSOKYO_SCARLET}

function s.initial_effect(c)
	-- Hiệu ứng (Quick Effect - Soft OPT): Nếu điều khiển quái thú "Gensokyo Scarlet", trục xuất lá này từ tay hoặc sân
	-- -> Bảo vệ kích hoạt của bài/hiệu ứng Dung hợp khỏi bị vô hiệu hóa + Khóa Extra Deck đến hết lượt
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND+LOCATION_ONFIELD)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E+TIMING_MAIN_END)
	e1:SetCountLimit(1) -- Soft OPT theo đúng dòng "Once per turn, if you control..."
	e1:SetCondition(s.condition)
	e1:SetCost(aux.bfgcost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end

--------------------------------------------------------------------------------
-- LOGIC BẢO VỆ KÍCH HOẠT FUSION & KHÓA EXTRA DECK ĐẾN HẾT LƯỢT
--------------------------------------------------------------------------------
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_GENSOKYO_SCARLET),tp,LOCATION_MZONE,0,1,nil)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- Không thể vô hiệu hóa việc kích hoạt của các bài hoặc hiệu ứng Triệu hồi Dung hợp đến hết lượt
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_INACTIVATE)
	e1:SetValue(s.effectfilter)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)

	-- Cấm Triệu hồi Đặc biệt từ Extra Deck đến hết lượt, trừ quái Fusion và quái Synchro/Xyz/Link/Pendulum "Gensokyo"
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetTargetRange(1,0)
	e2:SetTarget(s.splimit)
	e2:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e2,tp)
end

function s.effectfilter(e,ct)
	local te=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT)
	return te and te:IsHasCategory(CATEGORY_FUSION_SUMMON)
end

function s.splimit(e,c)
	if not c:IsLocation(LOCATION_EXTRA) then return false end
	return not (c:IsType(TYPE_FUSION) or (c:IsSetCard(SET_GENSOKYO) and c:IsType(TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK+TYPE_PENDULUM)))
end
