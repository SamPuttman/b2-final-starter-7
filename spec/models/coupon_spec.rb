require 'rails_helper'

RSpec.describe Coupon, type: :model do
  describe "relationships" do
    it { should belong_to :merchant }
  end

  describe "coupon_limit_validation" do
    before do
      @merchant = Merchant.create!(name: "J-Mart")
      5.times do |i|
        @merchant.coupons.create!(name: "Coupon #{i}", code: "CODE#{i}", discount_value: 10, discount_type: "percent_off")
      end
    end

    it "does not allow more than 5 coupons for a merchant" do
      new_coupon = @merchant.coupons.new(name: "New Coupon", code: "NEWCODE", discount_value: 15, discount_type: "percent_off")

      expect(new_coupon.valid?).to be false
      expect(new_coupon.errors[:base]).to include("Coupon limit reached. You can have a maximum of 5 coupons at a time.")
    end
  end

  describe "update coupon status" do
    it "toggles the status from active to inactive" do
      @merchant = Merchant.create!(name: "J-Mart")
      @coupon = Coupon.create!(name: "10OFF", code: "CODE10", discount_value: 10, discount_type: "Percent Off", merchant: @merchant)

      expect(@coupon.active?).to be true
      @coupon.update_status
      expect(@coupon.inactive?).to be true
    end

    it "toggles the status from inactive to active" do
      @merchant = Merchant.create!(name: "J-Mart")
      @coupon = Coupon.create!(name: "10OFF", code: "CODE10", discount_value: 10, discount_type: "Percent Off", merchant: @merchant, status: "inactive")

      expect(@coupon.inactive?).to be true
      @coupon.update_status
      expect(@coupon.active?).to be true
    end

  end
end
