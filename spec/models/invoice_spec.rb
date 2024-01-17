require 'rails_helper'

RSpec.describe Invoice, type: :model do
  describe "validations" do
    it { should validate_presence_of :status }
    it { should validate_presence_of :customer_id }
  end
  describe "relationships" do
    it { should belong_to :customer }
    it { should belong_to(:coupon).optional }
    it { should have_many(:items).through(:invoice_items) }
    it { should have_many(:merchants).through(:items) }
    it { should have_many :transactions}
  end

  before :each do
    @merchant1 = Merchant.create!(name: 'Hair Care')
    @item_1 = Item.create!(name: "Shampoo", description: "This washes your hair", unit_price: 10, merchant_id: @merchant1.id, status: 1)
    @item_8 = Item.create!(name: "Butterfly Clip", description: "This holds up your hair but in a clip", unit_price: 5, merchant_id: @merchant1.id)
    @customer_1 = Customer.create!(first_name: 'Joey', last_name: 'Smith')
    @invoice_1 = Invoice.create!(customer_id: @customer_1.id, status: 2, created_at: "2012-03-27 14:54:09")
    @ii_1 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_1.id, quantity: 9, unit_price: 10, status: 2)
    @ii_11 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_8.id, quantity: 1, unit_price: 10, status: 1)
  end

  describe "instance methods" do
    it "total_revenue" do

      expect(@invoice_1.total_revenue).to eq(100)
    end
  end

  describe "#grand_total" do
    it "equals the total revenue when no coupon is applied" do

      expect(@invoice_1.grand_total).to eq(100)
    end

    it "properly applies a percentage discount" do
      @coupon = Coupon.create!(name: "Discount", code: "OFF10", discount_value: 10, discount_type: "percent_off", merchant_id: @merchant1.id)
      @invoice_1.update(coupon: @coupon)

      expect(@invoice_1.grand_total).to eq(90)
    end

    it "properly applies a dollar discount" do
      @coupon = Coupon.create!(name: "5 Dollars Off", code: "5OFF", discount_value: 5, discount_type: "dollar_off", merchant_id: @merchant1.id)
      @invoice_1.update(coupon: @coupon)

      expect(@invoice_1.grand_total).to eq(95)
    end

    it "won't end up with a subzero total." do
      @coupon = Coupon.create!(name: "110 Dollars Off", code: "110FF", discount_value: 110, discount_type: "dollar_off", merchant_id: @merchant1.id)
      @invoice_1.update(coupon: @coupon)

      expect(@invoice_1.grand_total).to eq(0)
    end
  end
  
  describe "#applied_discount" do
    before :each do
      @merchant1 = Merchant.create!(name: "Hair Care")

      @item_1 = Item.create!(name: "Shampoo", description: "This washes your hair", unit_price: 100, merchant_id: @merchant1.id)
      
      @customer_1 = Customer.create!(first_name: "Joey", last_name: "Smith")
      @invoice_1 = Invoice.create!(customer_id: @customer_1.id, status: 2, created_at: "2012-03-27 14:54:09")

      @ii_1 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_1.id, quantity: 1, unit_price: @item_1.unit_price, status: 2)

      @coupon_percent = Coupon.create!(name: "10 Percent Off", code: "10FF", discount_value: 10, discount_type: "percent_off", merchant_id: @merchant1.id)
      @coupon_dollar = Coupon.create!(name: "20 Percent Off", code: "20FF", discount_value: 20, discount_type: "dollar_off", merchant_id: @merchant1.id)
      @invoice_1.update(coupon: @coupon)
    end

    it "returns 0 if no coupon is applied" do
      expected_discount = @invoice_1.send(:applied_discount)
      expect(expected_discount).to eq(0)
    end
  
    it "applies percent off discount correctly" do
      @invoice_1.update(coupon: @coupon_percent)
      
      expect(@invoice_1.send(:applied_discount)).to eq(@invoice_1.send(:calculate_percentage_discount))    
    end
  
    it "applies dollar off discount correctly" do
      @invoice_1.update(coupon: @coupon_dollar)
      
      expect(@invoice_1.send(:applied_discount)).to eq(@invoice_1.send(:calculate_fixed_discount))
    end
  end

  describe "invoice total sad paths" do
    before :each do
      @merchant1 = Merchant.create!(name: "Hair Care")
      @merchant2 = Merchant.create!(name: "Jewelry")

      @item_1 = Item.create!(name: "Shampoo", description: "This washes your hair", unit_price: 100, merchant_id: @merchant1.id)
      @item_2 = Item.create!(name: "Conditioner", description: "This makes your hair shiny", unit_price: 200, merchant_id: @merchant2.id,)
      
      @customer_1 = Customer.create!(first_name: "Joey", last_name: "Smith")
      @invoice_1 = Invoice.create!(customer_id: @customer_1.id, status: 2, created_at: "2012-03-27 14:54:09")

      @ii_1 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_1.id, quantity: 2, unit_price: @item_1.unit_price, status: 2)
      @ii_2 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_2.id, quantity: 1, unit_price: @item_2.unit_price, status: 2)

      @coupon = Coupon.create!(name: "10 Percent Off", code: "10FF", discount_value: 10, discount_type: "percent_off", merchant_id: @merchant1.id)
      @invoice_1.update(coupon: @coupon)
    end

    it "applies coupon discount only to items from the same merchant" do
      expected_subtotal = 400 
      expected_discount = 20 
      expected_grand_total = expected_subtotal - expected_discount
  
      expect(@invoice_1.total_revenue).to eq(expected_subtotal)
      expect(@invoice_1.discount_amount).to eq(expected_discount)
      expect(@invoice_1.grand_total).to eq(expected_grand_total)
    end
  end
end
