require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
#require 'pry'

use Rack::Session::Cookie, :key => 'rack.session',
                           :path => '/',
                           :secret => 'osc_secret' 



get '/' do
  #what's your name and how much would you like to bet
  erb :playerinfo
end

post '/playerinfo' do
  #store name and betting money in cookie
  redirect '/game'
end

get '/game' do
  #create deck, deal cards, total hands, display hands, buttons for betting
  erb :game
end

post '/gameaction' do
  #if statements to handle submission and change game state
  redirect '/game'
end


