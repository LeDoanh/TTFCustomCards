-- Gensokyo Scarlet - Flandre the Destruction
-- ID: 777700016
local s,id=GetID()

local SET_GENSOKYO		 = 0xa70
local SET_GENSOKYO_SCARLET = 0xd7c
local CARD_FLANDRE		 = 777700014 -- Gensokyo Scarlet - Flandre Scarlet

s.listed_series={SET_GENSOKYO,SET_GENSOKYO_SCARLET}
s.listed_names={CARD_FLANDRE}

function s.initial_effect(c)
	-- Quy tắc Triệu hồi Dung hợp: "Gensokyo Scarlet - Flandre Scarlet" + 1+ quái thú "Gensokyo"
	c:EnableReviveLimit()
	Fusion.AddProcMixRep(c,true,true,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_GENSOKYO),1,99,CARD_FLANDRE)

	-- Điều kiện Triệu hồi Đặc biệt: Phải được Triệu hồi Dung hợp trước, hoặc Triệu hồi Đặc biệt từ Extra Deck bằng cách trục xuất nguyên liệu từ tay/sân/Mộ
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

	-- Hiệu ứng 1: Khi được Triệu hồi Đặc biệt từ Extra Deck
	-- -> Phá hủy bài đối thủ điều khiển tối đa bằng số quái "Gensokyo Scarlet" khác tên trong Mộ & vùng trục xuất, sau đó gây 400 sát thương mỗi lá bị hủy
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.descon)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)

	-- Hiệu ứng 2 (Quick Effect): Trục xuất 1 quái thú đối thủ điều khiển, sau đó gây sát thương bằng ATK của nó và hồi LP bằng lượng sát thương đã gây
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_REMOVE+CATEGORY_DAMAGE+CATEGORY_RECOVER)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E+TIMING_MAIN_END)
	e3:SetCountLimit(1,{id,1})
	e3:SetTarget(s.rmtg)
	e3:SetOperation(s.rmop)
	c:RegisterEffect(e3)

	-- Hiệu ứng 3 (Dưới Mộ): Trả 800 LP -> Triệu hồi Đặc biệt lá bài này từ Mộ
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,3))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCountLimit(1,{id,2})
	e4:SetCost(s.gycost)
	e4:SetTarget(s.gytg)
	e4:SetOperation(s.gyop)
	c:RegisterEffect(e4)
end

--------------------------------------------------------------------------------
-- 1. LOGIC TRIỆU HỒI TỪ EXTRA DECK BẰNG CÁCH TRỤC XUẤT NGUYÊN LIỆU TỪ TAY/SÂN/MỘ
--------------------------------------------------------------------------------
function s.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA)
		or (st&SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION
		or se==e:GetLabelObject()
end

function s.matfilter(c)
	return c:IsSetCard(SET_GENSOKYO) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end

function s.rescon(sg,e,tp,mg)
	return #sg>=2 and sg:IsExists(Card.IsCode,1,nil,CARD_FLANDRE)
		and Duel.GetLocationCountFromEx(tp,tp,sg,e:GetHandler())>0
end

function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local g=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,0,nil)
	return aux.SelectUnselectGroup(g,e,tp,2,#g,s.rescon,0)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local g=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,0,nil)
	local sg=aux.SelectUnselectGroup(g,e,tp,2,#g,s.rescon,1,tp,HINTMSG_REMOVE,s.rescon,nil,true)
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
	Duel.Remove(sg,POS_FACEUP,REASON_COST)
	sg:DeleteGroup()
end

--------------------------------------------------------------------------------
-- 2. LOGIC PHÁ HỦY BÀI ĐỐI THỦ & GÂY 400 SÁT THƯƠNG MỖI LÁ KHI GỌI TỪ EXTRA DECK
--------------------------------------------------------------------------------
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonLocation(LOCATION_EXTRA)
end

function s.ctfilter(c)
	return c:IsSetCard(SET_GENSOKYO_SCARLET) and c:IsType(TYPE_MONSTER)
		and (not c:IsLocation(LOCATION_REMOVED) or c:IsFaceup())
end

function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local g=Duel.GetMatchingGroup(s.ctfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
		return g:GetClassCount(Card.GetCode)>0
			and Duel.IsExistingMatchingCard(nil,tp,0,LOCATION_ONFIELD,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,1-tp,LOCATION_ONFIELD)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,400)
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.ctfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
	local ct=g:GetClassCount(Card.GetCode)
	local og=Duel.GetMatchingGroup(nil,tp,0,LOCATION_ONFIELD,nil)
	if ct>0 and #og>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local sg=og:Select(tp,1,ct,nil)
		Duel.HintSelection(sg)
		local dc=Duel.Destroy(sg,REASON_EFFECT)
		if dc>0 then
			Duel.BreakEffect()
			Duel.Damage(1-tp,dc*400,REASON_EFFECT)
		end
	end
end

--------------------------------------------------------------------------------
-- 3. LOGIC TRỤC XUẤT 1 QUÁI ĐỐI THỦ, ĐỐT SÁT THƯƠNG BẰNG ATK & HỒI LP TƯƠNG ỨNG
--------------------------------------------------------------------------------
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_MZONE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_MZONE)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,0)
end

function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local tc=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,0,LOCATION_MZONE,1,1,nil):GetFirst()
	if tc then
		Duel.HintSelection(tc)
		local was_faceup=tc:IsFaceup()
		local prev_atk=tc:GetAttack()
		if Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_REMOVED) then
			local atk=was_faceup and prev_atk or tc:GetAttack()
			if atk>0 then
				Duel.BreakEffect()
				local dmg=Duel.Damage(1-tp,atk,REASON_EFFECT)
				if dmg>0 then
					Duel.Recover(tp,dmg,REASON_EFFECT)
				end
			end
		end
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