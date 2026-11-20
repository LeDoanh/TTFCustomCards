-- Gensokyo Scarlet - Gungnir of the Vampire
-- ID: 777700019
local s,id=GetID()

local SET_GENSOKYO		 = 0xa70
local SET_GENSOKYO_SCARLET = 0xd7c

s.listed_series={SET_GENSOKYO,SET_GENSOKYO_SCARLET}

function s.initial_effect(c)
	-- Quy tắc Phép Trang bị: Chỉ trang bị cho 1 quái thú bạn điều khiển
	aux.AddEquipProcedure(c,0)

	-- Hiệu ứng 1 (Nếu trang bị cho quái KHÔNG phải Fusion): Có thể thay thế cho 1 nguyên liệu Dung hợp "Gensokyo Scarlet"
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_FUSION_SUBSTITUTE)
	e1:SetCondition(s.subcon)
	e1:SetValue(s.subval)
	c:RegisterEffect(e1)

	-- Hiệu ứng 2 (Quick Effect - Nếu trang bị cho quái Fusion): Khi đối thủ kích hoạt bài/hiệu ứng phản hồi lại hiệu ứng của quái được trang bị
	-- -> Gửi lá này xuống Mộ; đổi hiệu ứng đó thành "Destroy 1 card you control, then draw 1 card"
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.chcon)
	e2:SetCost(s.chcost)
	e2:SetTarget(s.chtg)
	e2:SetOperation(s.chop)
	c:RegisterEffect(e2)

	-- Hiệu ứng 3 (Dưới Mộ - Trừ lượt được gửi xuống Mộ): Trục xuất lá này -> Lấy 1 quái thú từng làm nguyên liệu Dung hợp từ Mộ hoặc vùng trục xuất lên tay
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(aux.exccon)
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end

--------------------------------------------------------------------------------
-- 1. LOGIC THAY THẾ NGUYÊN LIỆU DUNG HỢP (KHI QUÁI TRANG BỊ KHÔNG PHẢI FUSION)
--------------------------------------------------------------------------------
function s.subcon(e)
	local ec=e:GetHandler():GetEquipTarget()
	return ec and not ec:IsType(TYPE_FUSION)
end

function s.subval(e,fc)
	return fc and fc:IsSetCard(SET_GENSOKYO_SCARLET)
end

--------------------------------------------------------------------------------
-- 2. LOGIC ĐỔI HIỆU ỨNG ĐỐI THỦ (KHI QUÁI TRANG BỊ LÀ FUSION)
--------------------------------------------------------------------------------
function s.chcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	if not (ec and ec:IsType(TYPE_FUSION) and ep==1-tp and ev>1) then return false end
	local prev_re=Duel.GetChainInfo(ev-1,CHAININFO_TRIGGERING_EFFECT)
	return prev_re and prev_re:IsActiveType(TYPE_MONSTER) and prev_re:GetHandler()==ec
end

function s.chcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() end
	Duel.SendtoGrave(c,REASON_COST)
end

function s.chtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,0,LOCATION_ONFIELD,1,nil)
		and Duel.IsPlayerCanDraw(1-tp,1) end
end

function s.chop(e,tp,eg,ep,ev,re,r,rp)
	local g=Group.CreateGroup()
	Duel.ChangeTargetCard(ev,g)
	Duel.ChangeChainOperation(ev,s.repop)
end

function s.repop(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetChainInfo(0,CHAININFO_TRIGGERING_PLAYER)
	Duel.Hint(HINT_SELECTMSG,p,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(p,nil,p,LOCATION_ONFIELD,0,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g)
		if Duel.Destroy(g,REASON_EFFECT)>0 then
			Duel.BreakEffect()
			Duel.Draw(p,1,REASON_EFFECT)
		end
	end
end

--------------------------------------------------------------------------------
-- 3. LOGIC THU HỒI QUÁI THÚ TỪNG LÀM NGUYÊN LIỆU DUNG HỢP TỪ MỘ / TRỤC XUẤT
--------------------------------------------------------------------------------
function s.thfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsReason(REASON_FUSION)
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
