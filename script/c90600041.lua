-- Sky Striker Special Maneuver - The Chosen One
-- ID: 90600041
local s,id=GetID()
function s.initial_effect(c)
	-- [1] Kích hoạt: Khóa hiệu ứng, chỉ được kích hoạt hiệu ứng quái thú "Sky Striker" trong phần còn lại của Duel
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(s.activate_op)
	c:RegisterEffect(e1)

	-- [2] Hiệu ứng Standby Phase: Khai báo 1 Loại Quái Thú để khóa hiệu ứng trong lượt
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.distg)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)

	-- [3] Hiệu ứng trong Mộ (Main Phase): Bỏ bản thân từ Mộ -> Thêm 1 Phép "Sky Striker" từ Deck lên tay (1 lượt mỗi tên)
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

	-- [4] Hiệu ứng chiến đấu: Khi quái thú "Sky Striker" chiến đấu + >=3 Phép trong Mộ -> Phá hủy 1 thẻ bài đối thủ (1 lượt mỗi tên)
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
-- [1] XỬ LÝ KHI KÍCH HOẠT
--------------------------------------------------------------------------------
function s.activate_op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ge1=Effect.CreateEffect(c)
	ge1:SetType(EFFECT_TYPE_FIELD)
	ge1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	ge1:SetCode(EFFECT_CANNOT_ACTIVATE)
	ge1:SetTargetRange(1,0)
	ge1:SetValue(s.aclimit)
	Duel.RegisterEffect(ge1,tp)
end
function s.aclimit(e,re,tp)
	local rc=re:GetHandler()
	return rc:IsMonster() and not rc:IsSetCard(SET_SKY_STRIKER)
end

--------------------------------------------------------------------------------
-- [2] XỬ LÝ STANDBY PHASE (Chọn giới hạn Chủng Tộc quái thú)
--------------------------------------------------------------------------------
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- Danh sách các chủng tộc theo đúng yêu cầu
	local allowed_races = RACE_AQUA | RACE_BEAST | RACE_BEASTWARRIOR | RACE_CREATORGOD 
		| RACE_CYBERSE | RACE_DINOSAUR | RACE_DIVINEBEAST | RACE_DRAGON | RACE_FAIRY 
		| RACE_FIEND | RACE_FISH | RACE_ILLUSION | RACE_INSECT | RACE_MACHINE 
		| RACE_PLANT | RACE_PSYCHIC | RACE_PYRO | RACE_REPTILE | RACE_ROCK 
		| RACE_SEASERPENT | RACE_SPELLCASTER | RACE_THUNDER | RACE_WARRIOR 
		| RACE_WINGEDBEAST | RACE_WYRM | RACE_ZOMBIE
		
	local rc=Duel.AnnounceRace(tp, 1, allowed_races)
	e:SetLabel(rc)
end

function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local rc=e:GetLabel()
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,1)
	e1:SetValue(function(eff,rebind,target_player)
		local rc_card=rebind:GetHandler()
		return rc_card:IsMonster() and rc_card:IsRace(eff:GetLabel())
	end)
	e1:SetLabel(rc)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end

--------------------------------------------------------------------------------
-- [3] XỬ LÝ TỪ MỘ (Thêm Phép "Sky Striker" từ Deck lên tay)
--------------------------------------------------------------------------------
function s.thfilter(c)
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
-- [4] XỬ LÝ KHI CHIẾN ĐẤU (Phá hủy 1 thẻ bài đối thủ nếu có >=3 Phép trong Mộ)
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
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g)
		Duel.Destroy(g,REASON_EFFECT)
	end
end