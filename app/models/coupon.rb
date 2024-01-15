class Coupon < ApplicationRecord
  belongs_to :merchant
  has_many :invoices

  validates :name, presence: true
  validates :code, presence: true, uniqueness: true
  validates :discount_value, presence: true
  validates :discount_type, presence: true

  enum discount_type: { percent_off: 0, dollar_off: 1 }

end