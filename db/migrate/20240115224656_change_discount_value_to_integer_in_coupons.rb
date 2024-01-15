class ChangeDiscountValueToIntegerInCoupons < ActiveRecord::Migration[7.0]
  def up
    change_column :coupons, :discount_value, 'integer USING CAST(discount_value AS integer)'
  end
  def down
    change_column :coupons, :discount_value, :float
  end
end
