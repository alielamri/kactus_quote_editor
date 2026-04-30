class ItemsController < ApplicationController
  before_action :set_quote
  before_action :set_item, only: [:edit, :update, :destroy]
  before_action :check_quote_not_validated, only: [:create, :update, :destroy]

  def create
    puts "create item #{params.inspect}"
    @item = @quote.items.build(item_params)
    if @item.save
      redirect_to @quote, notice: 'Item was successfully added.'
    else
      redirect_to @quote, alert: 'Unable to add item.'
    end
  end

  def edit
  end

  def update
    if @item.update(item_params)
      redirect_to @quote, notice: 'Item was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @item.destroy
    redirect_to @quote, notice: 'Item was successfully deleted.'
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

  def check_quote_not_validated
    redirect_to @quote, alert: 'Cannot modify items in a validated quote.' if @quote.draft? == false
  end
end
