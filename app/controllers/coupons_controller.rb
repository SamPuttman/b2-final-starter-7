class CouponsController < ApplicationController
  def index
    @merchant = Merchant.find(params[:merchant_id])
    @active_coupons = @merchant.coupons.where(status: "active")
    @inactive_coupons = @merchant.coupons.where(status: "inactive")
  end

  def new
    @merchant = Merchant.find(params[:merchant_id])
    @coupon = Coupon.new
  end

  def create
    @merchant = Merchant.find(params[:merchant_id])
    @coupon = @merchant.coupons.new(coupon_params)
  
    if @coupon.save
      redirect_to merchant_coupons_path(@merchant), notice: "Coupon created successfully."
    else
      flash[:alert] = @coupon.errors.full_messages.to_sentence
      redirect_to new_merchant_coupon_path(@merchant)
    end
  end

  def show
    @merchant = Merchant.find(params[:merchant_id])
    @coupon = @merchant.coupons.find(params[:id])
  end

  def update
    @merchant = Merchant.find(params[:merchant_id])
    @coupon = @merchant.coupons.find(params[:id])

    @coupon.update_status
    redirect_to merchant_coupon_path(@merchant, @coupon)
  end

  private

  def coupon_params
    params.require(:coupon).permit(:name, :code, :discount_value, :discount_type)
  end

end