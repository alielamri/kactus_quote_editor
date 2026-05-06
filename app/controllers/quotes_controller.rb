class QuotesController < ApplicationController
  before_action :set_quote, only: [ :edit, :update, :destroy ]
  before_action :set_quote_with_items, only: [ :show ]
  before_action :check_validated, only: [ :edit, :destroy ]
  before_action :check_validated_for_update, only: [ :update ]

  def index
    @quotes = Quote.recent
  end

  def show; end

  def new
    @quote = Quote.new
  end

  def create
    @quote = Quote.new(quote_params)
    if @quote.save
      redirect_to @quote, notice: I18n.t("flash.quotes.created")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @quote.update(quote_params)
      message = QuoteValidationService.validation_message_for(quote_params)
      redirect_to @quote, notice: message
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @quote.destroy
    redirect_to quotes_url, notice: I18n.t("flash.quotes.deleted")
  end

  private

  def set_quote
    @quote = Quote.find(params[:id])
  end

  def set_quote_with_items
    @quote = Quote.includes(:items).find(params[:id])
  end

  def quote_params
    params.require(:quote).permit(:name, :status)
  end

  def check_validated
    return if @quote.draft?

    redirect_to @quote, alert: I18n.t("flash.quotes.cannot_modify_validated")
  end

  def check_validated_for_update
    return if @quote.draft?

    redirect_to @quote, alert: I18n.t("flash.quotes.cannot_modify_validated")
  end
end
