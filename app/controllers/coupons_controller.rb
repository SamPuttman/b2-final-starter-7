class CouponsController < ApplicationController
  def index
    @merchant = Merchant.find(params[:merchant_id])
    @coupons = @merchant.coupons
  end
end