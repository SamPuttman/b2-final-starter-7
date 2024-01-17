require "rails_helper"

describe "Admin Invoices Index Page" do
  before :each do
    @m1 = Merchant.create!(name: "Merchant 1")

    @c1 = Customer.create!(first_name: "Yo", last_name: "Yoz", address: "123 Heyyo", city: "Whoville", state: "CO", zip: 12345)
    @c2 = Customer.create!(first_name: "Hey", last_name: "Heyz")

    @i1 = Invoice.create!(customer_id: @c1.id, status: 2, created_at: "2012-03-25 09:54:09")
    @i2 = Invoice.create!(customer_id: @c2.id, status: 1, created_at: "2012-03-25 09:30:09")

    @item_1 = Item.create!(name: "test", description: "lalala", unit_price: 6, merchant_id: @m1.id)
    @item_2 = Item.create!(name: "rest", description: "dont test me", unit_price: 12, merchant_id: @m1.id)

    @ii_1 = InvoiceItem.create!(invoice_id: @i1.id, item_id: @item_1.id, quantity: 12, unit_price: 2, status: 0)
    @ii_2 = InvoiceItem.create!(invoice_id: @i1.id, item_id: @item_2.id, quantity: 6, unit_price: 1, status: 1)
    @ii_3 = InvoiceItem.create!(invoice_id: @i2.id, item_id: @item_2.id, quantity: 87, unit_price: 12, status: 2)

    visit admin_invoice_path(@i1)
  end

  it "should display the id, status and created_at" do
    expect(page).to have_content("Invoice ##{@i1.id}")
    expect(page).to have_content("Created on: #{@i1.created_at.strftime("%A, %B %d, %Y")}")

    expect(page).to_not have_content("Invoice ##{@i2.id}")
  end

  it "should display the customers name and shipping address" do
    expect(page).to have_content("#{@c1.first_name} #{@c1.last_name}")
    expect(page).to have_content(@c1.address)
    expect(page).to have_content("#{@c1.city}, #{@c1.state} #{@c1.zip}")

    expect(page).to_not have_content("#{@c2.first_name} #{@c2.last_name}")
  end

  it "should display all the items on the invoice" do
    expect(page).to have_content(@item_1.name)
    expect(page).to have_content(@item_2.name)

    expect(page).to have_content(@ii_1.quantity)
    expect(page).to have_content(@ii_2.quantity)

    expect(page).to have_content("$#{@ii_1.unit_price}")
    expect(page).to have_content("$#{@ii_2.unit_price}")

    expect(page).to have_content(@ii_1.status)
    expect(page).to have_content(@ii_2.status)

    expect(page).to_not have_content(@ii_3.quantity)
    expect(page).to_not have_content("$#{@ii_3.unit_price}")
    expect(page).to_not have_content(@ii_3.status)
  end

  it "should display the total revenue the invoice will generate" do
    expect(page).to have_content("Total Revenue: $#{@i1.total_revenue}")

    expect(page).to_not have_content(@i2.total_revenue)
  end

  it "should have status as a select field that updates the invoices status" do
    within("#status-update-#{@i1.id}") do
      select("cancelled", :from => "invoice[status]")
      expect(page).to have_button("Update Invoice")
      click_button "Update Invoice"

      expect(current_path).to eq(admin_invoice_path(@i1))
      expect(@i1.status).to eq("completed")
    end
  end

  describe "admin invoice totals" do
    before do
      @merchant1 = Merchant.create!(name: "Hair Care")
      @customer_1 = Customer.create!(first_name: 'Joey', last_name: 'Smith')
      @invoice_1 = Invoice.create!(customer_id: @customer_1.id, status: 2, created_at: "2012-03-27 14:54:09")
      @coupon = Coupon.create!(name: "10 Dollars Off", code: "10FF", discount_value: 10, discount_type: "dollar_off", merchant_id: @merchant1.id)
    end

    it "shows the subtotal" do
      visit admin_invoice_path(@invoice_1)

      expect(page).to have_content("Subtotal: #{@invoice_1.total_revenue}")
    end

    it "shows the grand total" do
      @invoice_1.update(coupon: @coupon)

      @invoice_1.reload

      visit admin_invoice_path(@invoice_1)
      expect(page).to have_content("Grand Total: #{@invoice_1.grand_total}")
    end

    it "displays the coupon name as a link" do
      @invoice_1.update(coupon: @coupon)

      @invoice_1.reload

      visit admin_invoice_path(@invoice_1)
      expect(page).to have_content("#{@coupon.name}")
      expect(page).to have_content("#{@coupon.code}")
    end
  end

  describe "admin invoice total sad paths" do
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
