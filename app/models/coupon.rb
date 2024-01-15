class Coupon < ApplicationRecord
  belongs_to :merchant

  validates :name, presence: true
  validates :code, presence: true, uniqueness: true
  validates :discount_value, presence: true
  validates :discount_type, presence: true
end