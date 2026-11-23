-- Gensokyo Scarlet - Izayoi the Perfect Maid
-- ID: 777700017
local s,id=GetID()

local SET_GENSOKYO		 = 0xa70
local SET_GENSOKYO_SCARLET = 0xd7c
local CARD_SAKUYA		  = 777700009 -- Gensokyo Scarlet - Sakuya Izayoi

s.listed_series={SET_GENSOKYO,SET_GENSOKYO_SCARLET}
s.listed_names={CARD_SAKUYA}

function s.initial_effect(c)
	-- Quy tắc Triệu hồi Dung hợp: "Gensokyo Scarlet - Sakuya Izayoi" + 1+ quái thú "Gensokyo"
	c:EnableReviveLimit()
	Fusion.AddProcMixRep(c,true,true,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_GENSOKYO),1,99,CARD_SAKUYA)

	-- Điều kiện Triệu hồi Đặc biệt: Phải được Triệu hồi Dung hợp trước, hoặc Triệu hồi Đặc biệt từ Extra Deck bằng cách gửi nguyên liệu từ tay/sân xuống Mộ
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

	-- Hiệu ứng 1: Nếu được Triệu hồi Đặc biệt (không phải Triệu hồi Dung hợp) -> Lấy 1 Spell/Trap "Gensokyo Scarlet" từ Mộ hoặc vùng trục xuất lên tay
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)

	-- Hiệu ứng 2: Nếu được Triệu hồi Dung hợp -> Úp 1 Spell/Trap từ tay, Deck, Mộ hoặc vùng trục xuất lên sân (được kích hoạt ngay lượt này)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(s.setcon)
	e3:SetTarget(s.settg)
	e3:SetOperation(s.setop)
	c:RegisterEffect(e3)

	-- Hiệu ứng 3: Toàn bộ quái thú "Gensokyo" bạn điều khiển tăng 200 ATK/DEF cho mỗi nguyên liệu dùng để Triệu hồi Dung hợp lá này
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetCondition(s.atkcon)
	e4:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_GENSOKYO))
	e4:SetValue(s.atkval)
	c:RegisterEffect(e4)

	local e5=e4:Clone()
	e5:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e5)
end

--------------------------------------------------------------------------------
-- 1. LOGIC TRIỆU HỒI TỪ EXTRA DECK BẰNG CÁCH GỬI NGUYÊN LIỆU TỪ TAY / SÂN XUỐNG MỘ
--------------------------------------------------------------------------------
function s.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA)
		or (st&SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION
		or se==e:GetLabelObject()
end

function s.matfilter(c)
	return c:IsSetCard(SET_GENSOKYO) and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end

function s.rescon(sg,e,tp,mg)
	return #sg>=2 and sg:IsExists(Card.IsCode,1,nil,CARD_SAKUYA)
		and Duel.GetLocationCountFromEx(tp,tp,sg,e:GetHandler())>0
end

function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local g=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,nil)
	return aux.SelectUnselectGroup(g,e,tp,2,#g,s.rescon,0)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local g=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,nil)
	local sg=aux.SelectUnselectGroup(g,e,tp,2,#g,s.rescon,1,tp,HINTMSG_TOGRAVE,s.rescon,nil,true)
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
-- 2. LOGIC THU HỒI SPELL/TRAP "GENSOKYO SCARLET" KHI GỌI KHÔNG PHẢI DUNG HỢP
--------------------------------------------------------------------------------
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end

function s.thfilter(c)
	return c:IsSetCard(SET_GENSOKYO_SCARLET) and c:IsType(TYPE_SPELL+TYPE_TRAP)
		and (not c:IsLocation(LOCATION_REMOVED) or c:IsFaceup()) and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

--------------------------------------------------------------------------------
-- 3. LOGIC ÚP 1 SPELL/TRAP BẤT KỲ KHI FUSION SUMMON (KÍCH HOẠT ĐƯỢC NGAY LƯỢT NÀY)
--------------------------------------------------------------------------------
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end

function s.setfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
		and (not c:IsLocation(LOCATION_REMOVED) or c:IsFaceup()) and c:IsSSetable()
end

function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	Duel.SetPossibleOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,0)
end

function s.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.setfilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil):GetFirst()
	if tc and Duel.SSet(tp,tc)>0 then
		local c=e:GetHandler()
		-- Cho phép kích hoạt ngay trong lượt được úp nếu là Quick-Play Spell hoặc Trap
		if tc:IsType(TYPE_QUICKPLAY) then
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(aux.Stringid(id,3))
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
			e1:SetCode(EFFECT_QP_ACT_IN_SET_TURN)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		elseif tc:IsType(TYPE_TRAP) then
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(aux.Stringid(id,3))
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
			e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
	end
end

--------------------------------------------------------------------------------
-- 4. LOGIC TĂNG 200 ATK/DEF CHO QUÁI "GENSOKYO" THEO SỐ NGUYÊN LIỆU FUSION
--------------------------------------------------------------------------------
function s.atkcon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end

function s.atkval(e,c)
	return e:GetHandler():GetMaterialCount()*200
end