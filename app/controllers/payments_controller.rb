class PaymentsController < ApplicationController
  before_filter :ensure_active_payment, only: [:update, :show]

  def create
    session[:payment] = {
      id: SecureRandom.uuid,
      amount: params[:amount],
      address: params[:address],
      redirect_url: params[:redirect_url]
    }

    redirect_to payment_path(session[:payment][:id])
  end

  def show
  
  end

  def update
    if params[:next]
      session[:verified] = true
    end

    if params[:stripe_token]
      redirect_to session[:payment][:redirect_url]
      session[:payment] = nil
    else
      redirect_to payment_path(session[:payment][:id])
    end
  end

  private
  def ensure_active_payment
    return if session[:payment]
    redirect_to '/'
  end
end
