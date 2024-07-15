Rails.application.routes.draw do
  post "/query", to: "messages#send_query"
end
