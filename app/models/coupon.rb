class Coupon < ApplicationRecord
  belongs_to :merchant
  has_many :invoices
  has_many :transactions

  validates :name, presence: true
  validates :code, presence: true, uniqueness: { scope: :merchant_id }
  validates :discount_value, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :discount_type, presence: true
  validate :coupon_limit_validation, on: :create

  enum discount_type: { percent_off: "Percent Off", dollar_off: "Dollars Off"}
  enum status: { active: 0, inactive: 1 }

  #https://api.rubyonrails.org/v7.1.2/classes/ActiveModel/Errors.html

  def coupon_limit_validation
    if merchant && merchant.coupons.count >= 5
      errors.add(:base, "Coupon limit reached. You can have a maximum of 5 coupons at a time.")
    end
  end

  def usage_count
    transactions.count
  end

  def update_status
    if active? && cannot_deactivate_due_to_pending_invoice?
      return false
    else
      if active?
        self.status = :inactive
      else
        self.status = :active
      end
      save
    end
  end

  private

  def cannot_deactivate_due_to_pending_invoice?
    invoices.in_progress.exists?
  end

end