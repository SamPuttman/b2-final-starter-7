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
      expect(page).to have_content("Status: Active")
    end
  end
end