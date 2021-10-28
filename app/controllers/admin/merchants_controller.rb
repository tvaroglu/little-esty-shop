class Admin::MerchantsController < ApplicationController
  def index
    @enabled_merchants = Merchant.order_by_enabled
    @disabled_merchants = Merchant.order_by_disabled
    @top_merchants = Merchant.top_merchants_by_revenue
  end

  def show
    @merchant = Merchant.find(params[:id])
  end

  def new
  end

  def edit
    @merchant = Merchant.find(params[:id])
  end

  def create
    @merchant = Merchant.new(merchant_params)
    if @merchant.save
      redirect_to admin_merchants_path,
                  notice: "#{@merchant.name} successfully Created."
    else
      redirect_to new_admin_merchant_path
      flash[:alert] = "Don't Be Silly! Please Fill Out The Required Fields!"
    end
  end

  def update
    merchant = Merchant.find(params[:id])
    merchant.update(merchant_model_params)
    if params[:direct] == 'status change'
      return redirect_back(fallback_location: admin_merchants_path)
    end

    redirect_to admin_merchant_path(merchant.id),
                notice: 'Merchant successfully updated.'
  end

  private

  def merchant_params
    params.permit(:name)
  end

  def merchant_model_params
    params.require(:merchant).permit(:name, :status)
  end
end

# hidden field conditional
# def merchant_params
#   if params[:url] == 'present'
#     params.permit(:name)
#   else
#     params.require(:merchant).permit(:name)
#   end
# end
