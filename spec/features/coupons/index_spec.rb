RSpec.describe Coupon do
  describe "index" do
    before do
      @merchant = Merchant.create!(name: "J-Mart")
      @coupon1 = Coupon.create!(name: "10OFF", code: "CODE10", discount_value: 10, discount_type: "Percent Off", merchant: @merchant, status: "active")
      @coupon2 = Coupon.create!(name: "20OFF", code: "CODE20", discount_value: 20, discount_type: "Percent Off", merchant: @merchant, status: "active")
      @coupon3 = Coupon.create!(name: "30OFF", code: "CODE30", discount_value: 30, discount_type: "Dollars Off", merchant: @merchant, status: "inactive")
      @coupon4 = Coupon.create!(name: "40OFF", code: "CODE40", discount_value: 40, discount_type: "Dollars Off", merchant: @merchant, status: "inactive")
    end

    it "displays all coupons for the merchant" do
      expect(Coupon.exists?(@coupon1.id)).to be true
      expect(Coupon.exists?(@coupon2.id)).to be true
      expect(Coupon.exists?(@coupon3.id)).to be true
      expect(Coupon.exists?(@coupon4.id)).to be true

      visit merchant_coupons_path(@merchant)

      expect(page).to have_content("10OFF")
      expect(page).to have_content("20OFF")
      expect(page).to have_content("30OFF")
      expect(page).to have_content("40OFF")
    end

    it "shows active and inactive coupons in separate sections" do
      visit merchant_coupons_path(@merchant)
      
      #this sucked to differentiate but it works I think
      active_coupons_column = all(".column").first
      within(active_coupons_column) do
        expect(page).to have_content("Active Coupons")
        expect(page).to have_link(@coupon1.name)
        expect(page).to have_link(@coupon2.name)
      end

      within(".column", text: 'Inactive Coupons') do
        expect(page).to have_link(@coupon3.name)
        expect(page).to have_link(@coupon4.name)
      end
    end
  end
end