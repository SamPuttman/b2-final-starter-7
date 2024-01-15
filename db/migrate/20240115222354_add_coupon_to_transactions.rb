class AddCouponToTransactions < ActiveRecord::Migration[7.0]
  def change
    add_reference :transactions, :coupon, null: false, foreign_key: true, null: true
  end
end
