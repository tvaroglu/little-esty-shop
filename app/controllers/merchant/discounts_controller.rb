class Merchant::DiscountsController < ApplicationController

  def index
    @merchant = Merchant.find(params[:merchant_id])
    @discounts = @merchant.discounts
  end

  def show
    @merchant = Merchant.find(params[:merchant_id])
    @discount = Discount.find(params[:id])
  end

  def new
  end

  def edit
    @discount = Discount.find(params[:id])
  end

  def create
    @discount = Discount.new(discount_params)
    if @discount.save
      redirect_to merchant_discounts_path(params[:merchant_id])
      flash[:notice] = "Bulk discount successfully created."
    else
      redirect_to new_merchant_discount_path(params[:merchant_id])
      flash[:alert] = "All fields are required."
    end
  end

  def update
    discount = Discount.find(params[:id])
    discount.update(discount_model_params)
    redirect_to merchant_discount_path(discount.merchant_id, discount.id), notice: "Bulk discount successfully updated."
  end

  private
  def discount_params
    params.permit(:quantity_threshold, :percentage_discount, :status, :merchant_id)
  end

  def discount_model_params
    params.require(:discount).permit(:quantity_threshold, :percentage_discount, :status)
  end

end
