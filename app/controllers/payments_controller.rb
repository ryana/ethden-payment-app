class PaymentsController < ApplicationController
  before_action :ensure_active_payment, only: [:update, :show]

  def create
    session[:payment] = {
      'id' => SecureRandom.uuid,
      'amount' => params[:amount].to_f,
      'address' => params[:address],
      'redirect_url' => params[:redirect_url]
    }

    redirect_to payment_path(session[:payment]['id'])
  end

  def show
  
  end

  def update
    if params[:next]
      session[:payment]['verified'] = true
    end

    # The things we do on no sleep! :-D
    url = Rails.env.production? ?
      "https://quicketh-rinkeby.herokuapp.com/mint" :
      "http://localhost:5000/mint"

    if params[:stripe_token]
      addr = session[:payment]['address']
      amount = session[:payment]['amount']

      resp = Typhoeus::Request.post(url, body: {
        destinationAddress: addr,
        amount: amount
      }.to_json,
      headers: {
        'Content-Type' => 'application/json'
      });

      txid = JSON.parse(resp.body)['transactionId']

      rurl = session[:payment]['redirect_url']
      if rurl.include? "?"
        rurl << "&"
      else
        rurl << "?"
      end

      rurl << "quickethTxId=#{txid}"
      redirect_to rurl

      session[:payment] = nil
    else
      redirect_to payment_path(session[:payment]['id'])
    end
  end

  private
  def ensure_active_payment
    return if session[:payment]
    redirect_to '/'
  end
end
