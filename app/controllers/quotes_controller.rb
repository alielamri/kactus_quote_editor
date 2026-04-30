class QuotesController < ApplicationController
  before_action :set_quote, only: [:show, :edit, :update, :destroy]
  before_action :check_validated, only: [:edit, :destroy]
  before_action :check_validated_for_update, only: [:update]

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
      redirect_to @quote, notice: 'Quote was successfully created.'
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
    redirect_to quotes_url, notice: 'Quote was successfully deleted.'
  end

  private

  def set_quote
    @quote = Quote.find(params[:id])
  end

  def quote_params
    params.require(:quote).permit(:name, :status)
  end

  def check_validated
    redirect_to @quote, alert: 'Cannot modify a validated quote.' unless QuoteValidationService.can_modify?(@quote)
  end

  def check_validated_for_update
    return unless @quote.validated? && quote_params[:status].blank?
    # Only block updates if trying to modify name of a validated quote
    redirect_to @quote, alert: 'Cannot modify a validated quote.'
  end
end
