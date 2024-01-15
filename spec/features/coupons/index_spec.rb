RSpec.describe Coupon do
  describe "index" do
    before do
      @merchant = Merchant.create!(name: "J-Mart")
      @coupon1 = Coupon.create!(name: "10OFF", code: "CODE10", discount_value: 10.0, discount_type: 0, merchant: @merchant)
      @coupon2 = Coupon.create!(name: "20OFF", code: "CODE20", discount_value: 20.00, discount_type: 0, merchant: @merchant)
      @coupon3 = Coupon.create!(name: "30OFF", code: "CODE30", discount_value: 30.00, discount_type: 1, merchant: @merchant)
      @coupon4 = Coupon.create!(name: "40OFF", code: "CODE40", discount_value: 40.00, discount_type: 1, merchant: @merchant)
    end

    it "displays all coupons for the merchant" do
      expect(Coupon.exists?(@coupon1.id)).to be true
      expect(Coupon.exists?(@coupon2.id)).to be true

      visit merchant_coupons_path(@merchant)

      expect(page).to have_content("10OFF")
      expect(page).to have_content("20OFF")
    end
  end
end