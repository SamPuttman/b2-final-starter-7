class RemoveUniqueIndexFromCoupons < ActiveRecord::Migration[7.0]
  def change
    remove_index :coupons, :code
  end
end
