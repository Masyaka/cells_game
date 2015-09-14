set :server, 'thin'
set :sockets, []

configure do
  enable :cross_origin
end