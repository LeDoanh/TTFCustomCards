-- Sky Striker Airspace - Absolute Quarantine
-- ID: 90600055
local s,id=GetID()
function s.initial_effect(c)
	-- Kích hoạt lá bài Spell
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)

	-- Hiệu ứng 1: Mỗi lượt một lần - Target 1 card đối thủ điều khiển; phá hủy nó
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)

	-- Hiệu ứng 2: Quái thú được Normal hoặc Special Summon sẽ bị đổi sang tư thế Phòng thủ ngửa mặt, và không thể đổi tư thế chiến đấu
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetRange(LOCATION_SZONE)
	e3:SetOperation(s.posop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)

	-- Khóa đổi tư thế chiến đấu liên tục
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
	e5:SetRange(LOCATION_SZONE)
	e5:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e5:SetTarget(s.postg)
	c:RegisterEffect(e5)
end

s.listed_series={SET_SKY_STRIKER}

--------------------------------------------------------------------------------
-- KÍCH HOẠT: KHÓA HIỆU ỨNG QUÁI THÚ CHO ĐẾN HẾT TRẬN ĐẤU (REST OF DUEL)
--------------------------------------------------------------------------------
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- Trong phần còn lại của trận đấu sau khi kích hoạt, bạn không thể kích hoạt hiệu ứng quái thú ngoại trừ quái "Sky Striker"
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,0)
	e1:SetValue(s.actlimit)
	Duel.RegisterEffect(e1,tp)
end

function s.actlimit(e,re,tp)
	local rc=re:GetHandler()
	return re:IsActiveType(TYPE_MONSTER) and not rc:IsSetCard(SET_SKY_STRIKER)
end

--------------------------------------------------------------------------------
-- HIỆU ỨNG 1: PHÁ HỦY 1 LÁ BÀI CỦA ĐỐI THỦ
--------------------------------------------------------------------------------
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end

--------------------------------------------------------------------------------
-- HIỆU ỨNG 2: ĐỔI QUÁI THÚ MỚI TRIỆU HỒI SANG PHÒNG THỦ & KHÓA ĐỔI TƯ THẾ
--------------------------------------------------------------------------------
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(Card.IsFaceup,nil)
	if #g>0 then
		for tc in aux.Next(g) do
			if tc:IsPosition(POS_FACEUP_ATTACK) then
				Duel.ChangePosition(tc,POS_FACEUP_DEFENSE)
			end
			tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
		end
	end
end

function s.postg(e,c)
	return c:GetFlagEffect(id)~=0
end