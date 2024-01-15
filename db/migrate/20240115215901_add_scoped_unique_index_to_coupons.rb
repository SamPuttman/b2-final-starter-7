class AddScopedUniqueIndexToCoupons < ActiveRecord::Migration[7.0]
  def change
    add_index :coupons, [:code, :merchant_id], unique: true
  end
end
