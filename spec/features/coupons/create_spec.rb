RSpec.describe Coupon do
  describe "create" do
    before do
      @merchant = Merchant.create!(name: "J-Mart")
      @coupon1 = Coupon.create!(name: "10OFF", code: "CODE10", discount_value: 10.0, discount_type: 0, merchant: @merchant)
      @coupon2 = Coupon.create!(name: "20OFF", code: "CODE20", discount_value: 20.00, discount_type: 0, merchant: @merchant)
      @coupon3 = Coupon.create!(name: "30OFF", code: "CODE30", discount_value: 30.00, discount_type: 1, merchant: @merchant)
      @coupon4 = Coupon.create!(name: "40OFF", code: "CODE40", discount_value: 40.00, discount_type: 1, merchant: @merchant)
    end

    it "allows a merchant to create a coupon" do
      visit merchant_coupons_path(@merchant)

      click_link "Create New Coupon"

      fill_in "Name", with: "75OFF"
      fill_in "Code", with: "CODE75"
      fill_in "Discount value", with: "75"
      select "percent_off", from: "Discount type"

      click_button "Submit"

      expect(current_path).to eq(merchant_coupons_path(@merchant))
      expect(page).to have_content("75OFF")
    end

    it "won't let a merchant make more than 5 coupons" do
      @coupon5 = Coupon.create!(name: "50OFF", code: "CODE50", discount_value: 50.00, discount_type: 1, merchant: @merchant)

      visit merchant_coupons_path(@merchant)
      click_link "Create New Coupon"

      fill_in "Name", with: "100_OFF"
      fill_in "Code", with: "CODE100"
      fill_in "Discount value", with: "100"
      select "percent_off", from: "Discount type"

      click_button "Submit"

      expect(page).to have_content("Coupon limit reached. You can have a maximum of 5 coupons at a time.")
    end

    it "won't let a mechant create a duplicate coupon code" do
      visit merchant_coupons_path(@merchant)
      click_link "Create New Coupon"

      fill_in "Name", with: "10OFF"
      fill_in "Code", with: "CODE10"
      fill_in "Discount value", with: "10.0"
      select "dollar_off", from: "Discount type"

      click_button "Submit"

      expect(page).to have_content("Code has already been taken")
    end
  end
end