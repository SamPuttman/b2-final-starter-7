class Transaction < ApplicationRecord
  validates_presence_of :invoice_id,
                        :credit_card_number,
                        :result
  enum result: [:failed, :success]

  belongs_to :invoice
  belongs_to :coupon, optional: true

  def process_transaction(params)
      
    if params[:coupon_code]
      coupon = Coupon.find_by(code: params[:coupon_code])
      transaction.coupon = coupon if coupon.present? && coupon.active?
    end
  
    transaction.save
  end
end
