RSpec.describe Coupon do
  describe "show" do
    before do
      @merchant = Merchant.create!(name: "J-Mart")
      @coupon1 = Coupon.create!(name: "10OFF", code: "CODE10", discount_value: 10, discount_type: "Percent Off", merchant: @merchant)
    end

    it "shows correct coupon information" do
      visit merchant_coupon_path(@merchant, @coupon1)
  
      expect(page).to have_content(@coupon1.name)
      expect(page).to have_content(@coupon1.code)
      expect(page).to have_content("Discount: 10")
      expect(page).to have_content("Status: active")
    end

    it "allows merchants to toggle coupon status" do
      visit merchant_coupon_path(@merchant, @coupon1)

      expect(page).to have_content(@coupon1.name)
      expect(page).to have_content(@coupon1.code)
      expect(page).to have_content("Discount: 10")
      expect(page).to have_content("Status: active")

      expect(page).to have_content("Deactivate Coupon")
      click_button "Deactivate Coupon"
      
      visit current_path
      expect(page).to have_content("Status: inactive")
    end
  end
end