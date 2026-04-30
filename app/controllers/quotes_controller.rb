class QuotesController < ApplicationController
  before_action :set_quote, only: [:show, :edit, :update, :destroy, :validate]
  before_action :check_validated, only: [:edit, :update, :destroy]

  def index
    @quotes = Quote.recent
  end

  def show
  end

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

  def edit
  end

  def update
    if @quote.update(quote_params)
      redirect_to @quote, notice: 'Quote was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @quote.destroy
    redirect_to quotes_url, notice: 'Quote was successfully deleted.'
  end

  def validate
    if @quote.update(status: :validated)
      redirect_to @quote, notice: 'Quote was successfully validated.'
    else
      redirect_to @quote, alert: 'Unable to validate quote.'
    end
  end

  private

  def set_quote
    @quote = Quote.find(params[:id])
  end

  def quote_params
    params.require(:quote).permit(:name)
  end

  def check_validated
    redirect_to @quote, alert: 'Cannot modify a validated quote.' if @quote.draft? == false
  end
end
