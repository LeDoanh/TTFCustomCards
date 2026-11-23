-- Gensokyo Scarlet - Red Magic Fusion
-- ID: 777700021
local s,id=GetID()

local SET_GENSOKYO		 = 0xa70
local SET_GENSOKYO_SCARLET = 0xd7c

s.listed_series={SET_GENSOKYO,SET_GENSOKYO_SCARLET}

function s.initial_effect(c)
	-- Hiệu ứng 1: Triệu hồi Dung hợp 1 quái "Gensokyo Scarlet" bằng nguyên liệu trên tay/sân,
	-- HOẶC trục xuất nguyên liệu từ Deck/Mộ và trả 400 LP cho mỗi quái bị trục xuất + Khóa Extra Deck
	local fparams_std={
		handler=c,
		fusfilter=aux.FilterBoolFunction(Card.IsSetCard,SET_GENSOKYO_SCARLET)
	}
	local fparams_ban={
		handler=c,
		fusfilter=aux.FilterBoolFunction(Card.IsSetCard,SET_GENSOKYO_SCARLET),
		matfilter=aux.FALSE,
		extrafil=s.fextra,
		extraop=s.banop,
		extratg=s.extratg,
		fcheck=s.fcheck
	}
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target(fparams_std,fparams_ban))
	e1:SetOperation(s.activate(fparams_std,fparams_ban))
	c:RegisterEffect(e1)

	-- Hiệu ứng 2 (Dưới Mộ): Nếu quái Dung hợp "Gensokyo Scarlet" bạn điều khiển rời sân -> Trả 400 LP; lấy lá này về tay (HOPT)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.thcon)
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end

--------------------------------------------------------------------------------
-- 1. LOGIC TRIỆU HỒI DUNG HỢP (TAY/SÂN HOẶC TRỤC XUẤT DECK/MỘ + TRẢ 400 LP/QUÁI)
--------------------------------------------------------------------------------
function s.banfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToRemove()
end

function s.fextra(e,tp,mg)
	return Duel.GetMatchingGroup(aux.NecroValleyFilter(s.banfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,nil)
end

function s.fcheck(tp,sg,fc)
	return Duel.CheckLPCost(tp,#sg*400)
end

function s.banop(e,tc,tp,sg)
	local ct=Duel.Remove(sg,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
	sg:Clear()
	if ct>0 then
		Duel.PayLPCost(tp,ct*400)
	end
end

function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end

function s.target(fparams_std,fparams_ban)
	return function(e,tp,eg,ep,ev,re,r,rp,chk)
		local b1=Fusion.SummonEffTG(fparams_std)(e,tp,eg,ep,ev,re,r,rp,0)
		local b2=Fusion.SummonEffTG(fparams_ban)(e,tp,eg,ep,ev,re,r,rp,0)
		if chk==0 then return b1 or b2 end
		local op=Duel.SelectEffect(tp,
			{b1,aux.Stringid(id,2)},
			{b2,aux.Stringid(id,3)})
		e:SetLabel(op)
		if op==1 then
			Fusion.SummonEffTG(fparams_std)(e,tp,eg,ep,ev,re,r,rp,1)
		else
			Fusion.SummonEffTG(fparams_ban)(e,tp,eg,ep,ev,re,r,rp,1)
		end
	end
end

function s.activate(fparams_std,fparams_ban)
	return function(e,tp,eg,ep,ev,re,r,rp)
		if e:GetLabel()==1 then
			Fusion.SummonEffOP(fparams_std)(e,tp,eg,ep,ev,re,r,rp)
		else
			Fusion.SummonEffOP(fparams_ban)(e,tp,eg,ep,ev,re,r,rp)
		end
		-- Cấm Triệu hồi Đặc biệt từ Extra Deck đến hết lượt, trừ quái Fusion và quái Synchro/Xyz/Link/Pendulum "Gensokyo"
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id,4))
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

--------------------------------------------------------------------------------
-- 2. LOGIC THU HỒI LÁ NÀY TỪ MỘ KHI QUÁI FUSION "GENSOKYO SCARLET" RỜI SÂN
--------------------------------------------------------------------------------
function s.thcfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsPreviousPosition(POS_FACEUP)
		and c:IsPreviousSetCard(SET_GENSOKYO_SCARLET)
		and (c:GetPreviousTypeOnField()&TYPE_FUSION)~=0
end

function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.thcfilter,1,nil,tp)
end

function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,400) end
	Duel.PayLPCost(tp,400)
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,tp,LOCATION_GRAVE)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,c)
	end
end