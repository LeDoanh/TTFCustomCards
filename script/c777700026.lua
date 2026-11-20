-- Gensokyo Nether - Merlin Prismriver
-- ID: 777700026
local s,id=GetID()

local SET_GENSOKYO		= 0xa70
local SET_GENSOKYO_NETHER = 0xd6c
local SET_PRISMRIVER	  = 0x1d6c -- Sub-setcode đại diện cho từ khóa "Prismriver"

s.listed_series={SET_GENSOKYO,SET_GENSOKYO_NETHER,SET_PRISMRIVER}
s.listed_names={id}

function s.initial_effect(c)
	-- Hiệu ứng 1: Có thể được coi là Tuner khi Triệu hồi Đồng bộ quái thú "Gensokyo Nether"
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_CAN_BE_TUNER)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(aux.TargetBoolFunction(Card.IsSetCard,SET_GENSOKYO_NETHER))
	c:RegisterEffect(e1)

	-- Hiệu ứng 2 (Quick Effect - Trên tay): Chọn 1 quái "Gensokyo Nether" trên sân của bạn
	-- -> Triệu hồi Đặc biệt lá này, ngay sau đó Triệu hồi Đồng bộ 1 quái "Gensokyo Nether" dùng lá này làm nguyên liệu
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_HAND)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E+TIMING_MAIN_END)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)

	-- Hiệu ứng 3: Khi bị gửi xuống Mộ làm nguyên liệu Triệu hồi Đồng bộ
	-- -> Search 1 lá "Gensokyo Nether" có nhắc đến "Prismriver" trong text từ Deck (trừ chính lá này)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(s.thcon)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end

--------------------------------------------------------------------------------
-- 1. LOGIC QUICK EFFECT TRIỆU HỒI TỪ TAY -> SYNCHRO SUMMON NGAY LẬP TỨC
--------------------------------------------------------------------------------
function s.tgfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_GENSOKYO_NETHER)
end

function s.scfilter(c)
	return c:IsSetCard(SET_GENSOKYO_NETHER) and c:IsType(TYPE_SYNCHRO)
end

function s.synfilter(c)
	return c:IsSetCard(SET_GENSOKYO_NETHER) and c:IsSynchroSummonable(nil)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.tgfilter(chkc) end
	local c=e:GetHandler()
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
			and Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_MZONE,0,1,nil)
			and Duel.IsExistingMatchingCard(s.scfilter,tp,LOCATION_EXTRA,0,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,LOCATION_HAND)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- Ép buộc sử dụng chính lá bài này làm nguyên liệu (có thể đóng vai trò Tuner hoặc Non-Tuner)
		Synchro.CheckAdditional=function(tp,sg,sc) return sg:IsContains(c) end
		local syng=Duel.GetMatchingGroup(s.synfilter,tp,LOCATION_EXTRA,0,nil)
		if #syng>0 then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sc=syng:Select(tp,1,1,nil):GetFirst()
			Duel.SynchroSummon(tp,sc,nil)
		end
		Synchro.CheckAdditional=nil
	end
end

--------------------------------------------------------------------------------
-- 2. LOGIC SEARCH LÁ "GENSOKYO NETHER" NHẮC ĐẾN "PRISMRIVER" KHI LÀM NGUYÊN LIỆU SYNCHRO
--------------------------------------------------------------------------------
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (r&REASON_SYNCHRO)~=0 and c:IsLocation(LOCATION_GRAVE)
end

function s.thfilter(c)
	return c:IsSetCard(SET_GENSOKYO_NETHER) and not c:IsCode(id) and c:IsAbleToHand()
		and (c:ListsArchetype(SET_PRISMRIVER) or c:ListsCodeWithArchetype(SET_PRISMRIVER) or c:ListsCode(id))
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