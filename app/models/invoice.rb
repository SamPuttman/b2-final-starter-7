class Invoice < ApplicationRecord
  validates_presence_of :status,
                        :customer_id

  belongs_to :customer
  belongs_to :coupon, optional: true
  has_many :transactions
  has_many :invoice_items
  has_many :items, through: :invoice_items
  has_many :merchants, through: :items

  enum status: [:cancelled, :in_progress, :completed]

  def total_revenue
    invoice_items.sum("unit_price * quantity")
  end

  def grand_total
    if coupon
      total_revenue - applied_discount
    else
      total_revenue
    end
  end

  private

  def applied_discount
    return 0 unless coupon

    if coupon.discount_type == 'percent_off'
      calculate_percentage_discount
    else coupon.discount_type == 'dollar_off'
      calculate_fixed_discount
    end
  end

  def calculate_percentage_discount
    total_revenue * (coupon.discount_value.to_f / 100)
  end

  def calculate_fixed_discount
    [coupon.discount_value, total_revenue].min
  end
end

