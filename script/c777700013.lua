-- Gensokyo Scarlet - Remilia Scarlet
-- ID: 777700013
local s,id=GetID()

local SET_GENSOKYO		 = 0xa70
local SET_GENSOKYO_SCARLET = 0xd7c

s.listed_series={SET_GENSOKYO,SET_GENSOKYO_SCARLET}

function s.initial_effect(c)
	-- Hiệu ứng 1: Khi được Triệu hồi Đặc biệt -> Trục xuất lá bài này khi rời sân
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetOperation(s.rmop)
	c:RegisterEffect(e1)

	-- Hiệu ứng 2: Trả 800 LP -> Triệu hồi Đặc biệt lá bài này từ tay hoặc Mộ (chỉ được triệu hồi 1 lần/lượt bằng cách này)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)

	-- Hiệu ứng 3 (Soft OPT): Ngay sau khi được Triệu hồi Đặc biệt
	-- -> Triệu hồi Dung hợp 1 quái "Gensokyo Scarlet" bằng cách xào nguyên liệu từ tay/sân/Mộ/trục xuất về Deck + Khóa Extra Deck
	local fparams={
		handler=c,
		fusfilter=aux.FilterBoolFunction(Card.IsSetCard,SET_GENSOKYO_SCARLET),
		matfilter=Fusion.OnFieldMat(Card.IsAbleToDeck),
		extrafil=s.fextra,
		extraop=Fusion.ShuffleMaterial,
		extratg=s.extratg
	}
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCountLimit(1)
	e3:SetTarget(s.fustg(fparams))
	e3:SetOperation(s.fusop(fparams))
	c:RegisterEffect(e3)
end

--------------------------------------------------------------------------------
-- 1. LOGIC TRỤC XUẤT KHI RỜI SÂN
--------------------------------------------------------------------------------
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(3300)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		c:RegisterEffect(e1,true)
	end
end

--------------------------------------------------------------------------------
-- 2. LOGIC TRẢ 800 LP ĐỂ TRIỆU HỒI TỪ TAY HOẶC MỘ
--------------------------------------------------------------------------------
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,800) end
	Duel.PayLPCost(tp,800)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end

--------------------------------------------------------------------------------
-- 3. LOGIC TRIỆU HỒI DUNG HỢP & KHÓA EXTRA DECK ĐẾN HẾT LƯỢT
--------------------------------------------------------------------------------
function s.exfilter(c)
	return c:IsType(TYPE_MONSTER) and (not c:IsLocation(LOCATION_REMOVED) or c:IsFaceup()) and c:IsAbleToDeck()
end

function s.fextra(e,tp,mg)
	return Duel.GetMatchingGroup(aux.NecroValleyFilter(s.exfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
end

function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED)
end

function s.fustg(fparams)
	return function(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return true end
		Fusion.SummonEffTG(fparams)(e,tp,eg,ep,ev,re,r,rp,chk)
	end
end

function s.fusop(fparams)
	return function(e,tp,eg,ep,ev,re,r,rp)
		Fusion.SummonEffOP(fparams)(e,tp,eg,ep,ev,re,r,rp)
		-- Cấm Triệu hồi Đặc biệt từ Extra Deck đến hết lượt, trừ quái Fusion và quái Synchro/Xyz/Link/Pendulum "Gensokyo"
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id,3))
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetTargetRange(1,0)
		e1:SetTarget(s.splimit)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end

function s.splimit(e,c)
	if not c:IsLocation(LOCATION_EXTRA) then return false end
	return not (c:IsType(TYPE_FUSION) or (c:IsSetCard(SET_GENSOKYO) and c:IsType(TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK+TYPE_PENDULUM)))
end
