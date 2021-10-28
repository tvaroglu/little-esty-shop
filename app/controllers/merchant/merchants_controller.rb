class Merchant::MerchantsController < ApplicationController
  def index
    @merchants = if params[:format] == 'name'
                   Merchant.order_by_name(:name)
                 elsif params[:format] == 'date'
                   Merchant.order_by_date(:updated_at, :desc)
                 else
                   Merchant.all
                 end
  end

  def new
  end

  def edit
  end

  def create
  end

  def update
  end
end
