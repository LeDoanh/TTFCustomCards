-- Sky Striker Special Maneuver - The Chosen One
-- ID: 90600041
local s,id=GetID()
function s.initial_effect(c)
	-- Kích hoạt bài phép thông thường
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(s.actop)
	c:RegisterEffect(e1)

	-- Hiệu ứng 1: Trong Standby Phase của mỗi lượt, gọi tên 1 Loại Quái Thú (Monster Type) để khóa hiệu ứng
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.distg)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)

	-- Hiệu ứng 2: Bỏ loại bỏ từ Mộ (GY) trong Main Phase -> Thêm 1 Phép "Sky Striker" từ Deck lên tay
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,{id,2})
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)

	-- Hiệu ứng 3: Khi quái thú "Sky Striker" của bạn chiến đấu (có từ 3 Phép trở lên trong Mộ) -> Phá hủy 1 thẻ bài đối thủ
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,3))
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_BATTLE_CONFIRMED)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1,{id,3})
	e4:SetCondition(s.descon)
	e4:SetTarget(s.destg)
	e4:SetOperation(s.desop)
	c:RegisterEffect(e4)
end

s.listed_series={SET_SKY_STRIKER}

--------------------------------------------------------------------------------
-- KHI KÍCH HOẠT: Giới hạn chỉ được kích hoạt hiệu ứng của quái thú "Sky Striker" trong phần còn lại của ván đấu
--------------------------------------------------------------------------------
function s.actop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.aclimit)
	e1:SetReset(RESET_PHASE|PHASE_END) -- (Hoặc bỏ reset nếu muốn khóa suốt ván như dòng text tiếng Anh)
	-- Nếu theo đúng text "for the rest of this duel", ta dùng đoạn dưới:
	-- (Hệ thống YGOPro dùng global flag hoặc cấm activate không giới hạn pha)
end

-- Hàm phụ trợ khóa hiệu ứng ngoài "Sky Striker" suốt ván đấu
function s.initial_effect(c)
	-- (Phần gộp hiệu ứng chuẩn)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(s.activation_limit)
	c:RegisterEffect(e1)

	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.distg)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)

	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,{id,2})
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)

	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,3))
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_BATTLE_CONFIRMED)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1,{id,3})
	e4:SetCondition(s.descon)
	e4:SetTarget(s.destg)
	e4:SetOperation(s.desop)
	c:RegisterEffect(e4)
end

function s.activation_limit(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.aclimit)
	Duel.RegisterEffect(e1,tp)
end
function s.aclimit(e,re,tp)
	local rc=re:GetHandler()
	return rc:IsMonster() and not rc:IsSetCard(SET_SKY_STRIKER)
end

--------------------------------------------------------------------------------
-- HIỆU ỨNG 1: Khai báo Loại Quái Thú (Monster Type) trong Standby Phase
--------------------------------------------------------------------------------
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- Đưa ra thông báo chọn Loại Quái Thú (Race)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CARDTYPE)
	local rc=Duel.AnnounceRace(tp,1,RACE_ALL)
	e:SetLabel(rc)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local rc=e:GetLabel()
	local c=e:GetHandler()
	-- Cả hai người chơi không thể kích hoạt hiệu ứng của quái thú thuộc loại đã khai báo trong lượt này
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,1)
	e1:Setvalue(s.aclimit2)
	e1:SetLabel(rc)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.aclimit2(e,re,tp)
	local rc=re:GetHandler()
	return rc:IsMonster() and rc:IsRace(e:GetLabel())
end

--------------------------------------------------------------------------------
-- HIỆU ỨNG 2: Bỏ bản thân từ Mộ -> Thêm Phép "Sky Striker" từ Deck lên tay
--------------------------------------------------------------------------------
function s.thfilter(c)
	local huan_name, _ = c:IsSetCard(SET_SKY_STRIKER), c:IsType(TYPE_SPELL)
	return c:IsSetCard(SET_SKY_STRIKER) and c:IsSpell() and c:IsAbleToHand()
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

--------------------------------------------------------------------------------
-- HIỆU ỨNG 3: Khi quái thú "Sky Striker" chiến đấu + >=3 Phép trong Mộ -> Phá hủy 1 bài đối thủ
--------------------------------------------------------------------------------
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetBattleMonster(tp)
	return tc and tc:IsFaceup() and tc:IsSetCard(SET_SKY_STRIKER) 
		and Duel.GetMatchingGroupCount(Card.IsSpell,tp,LOCATION_GRAVE,0,nil)>=3
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_CATEGORY_DESTROY,g,1,1,0)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget() -- Hoặc lấy từ hiệu ứng chọn mục tiêu
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g)
		Duel.Destroy(g,REASON_EFFECT)
	end
end