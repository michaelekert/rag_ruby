class MessagesController < ApplicationController
  def send_query
    operation = MainService.call(params[:message])
    if operation.success?
      render json: {response: operation.result}
    else
      render json: operation.errors
    end
  end
end
