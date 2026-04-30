class ItemsController < ApplicationController
  before_action :set_quote
  before_action :set_item, only: [:edit, :update, :destroy]

  def create
    result = ItemManagementService.create_item(@quote, item_params)
    if result[:success]
      redirect_to @quote, notice: result[:message]
    else
      redirect_to @quote, alert: result[:error]
    end
  end

  def edit
  end

  def update
    result = ItemManagementService.update_item(@item, item_params)
    if result[:success]
      redirect_to @quote, notice: result[:message]
    else
      redirect_to @quote, alert: result[:error]
    end
  end

  def destroy
    result = ItemManagementService.destroy_item(@item)
    if result[:success]
      redirect_to @quote, notice: result[:message]
    else
      redirect_to @quote, alert: result[:error]
    end
  end

  private

  def set_quote
    @quote = Quote.find(params[:quote_id])
  end

  def set_item
    @item = @quote.items.find(params[:id])
  end

  def item_params
    params.require(:item).permit(:name, :quantity, :unit_price, :vat_rate)
  end
end
