require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'pry'

use Rack::Session::Cookie, :key => 'rack.session',
                           :path => '/',
                           :secret => 'osc_secret' 


BLACKJACK_AMOUNT = 21
DEALER_MIN_HIT = 17

helpers do
  def calculate_total(cards)
    total = 0    
    cards.each do |card|
      if card.last.kind_of?(Integer)
        total += card.last
      elsif ['J', 'Q', 'K'].include?(card.last)
        total += 10
      else
        total += 11 # need to fix for aces
      end
    end
    if total > 21
      aces = cards.count {|card| card.last == 'A'}
      while aces > 0 && total > 21 do 
        total -= 10
        aces -= 1
      end 
    end
    total
  end

  def card_converter(cards)
    hand_images = []
    cards.each do |card|
      card_image = ""
      case card.first
        when 'C'
          card_image += '/images/cards/clubs_'
        when 'H'
          card_image += '/images/cards/hearts_'
        when 'D'
          card_image += '/images/cards/diamonds_'
        else 'S'
          card_image += '/images/cards/spades_'       
      end

      case card.last
        when 2
          card_image += '2.jpg'
        when 3
          card_image += '3.jpg'
        when 4
          card_image += '4.jpg'
        when 5
          card_image += '5.jpg'
        when 6
          card_image += '6.jpg'
        when 7
          card_image += '7.jpg'
        when 8
          card_image += '8.jpg'
        when 9
          card_image += '9.jpg'
        when 10
          card_image += '10.jpg'
        when 'A'
          card_image += 'ace.jpg'
        when 'J'
          card_image += 'jack.jpg'
        when 'Q'
          card_image += 'queen.jpg'
        when 'K'
          card_image += 'king.jpg'       
      end
      hand_images << card_image
    end
    hand_images
  end

  def determine_player_message(player_total)
    return "You've got blackjack!" if player_total == 21 
    return "Would you like to hit or stay?" if player_total < 21 
    return "You've busted!" if player_total > 21 
  end

  def winner!(msg)
    @show_hit_or_stay_buttons = false
    @gameover = true
    @success = "<strong>#{session[:player_name]} wins!</strong> #{msg}"
  end

  def loser!(msg)
    @show_hit_or_stay_buttons = false
    @gameover = true
    @error = "<strong>#{session[:player_name]} loses!</strong> #{msg}"
  end

  def tie!(msg)
    @gameover = true
    @success = "<strong> It's a tie!</strong> #{msg}"
  end
end

before do
  @show_hit_or_stay_buttons = true
  @show_hole_card = false
  @gameover = false
end

get '/' do
  if session[:player_name]
    redirect '/game'
  else
    redirect '/new_player'
  end
end

get '/new_player' do
  erb :new_player
end

post '/new_player' do

  if params[:player_name].empty?
    @error = "Name is required. "
    halt erb :new_player
  end
  session[:player_name] = params[:player_name]
  redirect '/game'
end

get '/game' do

  #create deck
  suits =['S', 'C', 'D', 'H']
  values = [2, 3, 4, 5, 6, 7, 8, 9, 10, 'J', 'Q', 'K', 'A']
  session[:deck] = suits.product(values).shuffle
  session[:turn] = session[:player_name]

  #deal cards
  session[:dealer_cards] = []
  session[:player_cards] = []
  session[:dealer_cards] << session[:deck].pop
  session[:player_cards] << session[:deck].pop 
  session[:dealer_cards] << session[:deck].pop
  session[:player_cards] << session[:deck].pop  

  @player_array = card_converter(session[:player_cards])
  @dealer_array = card_converter(session[:dealer_cards])
  if calculate_total(session[:player_cards]) == BLACKJACK_AMOUNT
    @success = "#{session[:player_name]} has blackjack"
    @gameover = true
  end

  erb :game
end

post '/game/player/hit' do
    session[:player_cards] << session[:deck].pop
    player_total = calculate_total(session[:player_cards])
    if player_total == BLACKJACK_AMOUNT
      winner!("#{session[:player_name]} hit blackjack.")
    elsif player_total > BLACKJACK_AMOUNT
      loser!("It looks like #{session[:player_name]} busted.")
    end  
    erb :game, layout: false
end

post '/game/player/stay' do
  @show_hit_or_stay_buttons = false
  @show_hole_card = true
  session[:turn] = "dealer"
  dealer_total = calculate_total(session[:dealer_cards])
  player_total = calculate_total(session[:player_cards])
  if dealer_total == BLACKJACK_AMOUNT
    loser!("Dealer has blackjack.")
  elsif dealer_total > player_total && dealer_total >= DEALER_MIN_HIT
    loser!("Dealer has #{dealer_total} while #{session[:player_name]} has #{player_total}.")
  elsif dealer_total == player_total && dealer_total >= DEALER_MIN_HIT
    tie!(" Dealer and #{session[:player_name]} both have #{player_total}.")
  else 
    @success = "#{session[:player_name]} has chosen to stay."
  end
  erb :game
end

post '/game/dealer/hit' do
  @show_hit_or_stay_buttons = false
  @show_hole_card = true
  session[:turn]  = "dealer"

  session[:dealer_cards] << session[:deck].pop
  dealer_total = calculate_total(session[:dealer_cards])

  if dealer_total > BLACKJACK_AMOUNT
    winner!("The dealer has busted with #{dealer_total}.")
  elsif dealer_total == BLACKJACK_AMOUNT
    loser!("The dealer has blackjack.")
  elsif dealer_total >= DEALER_MIN_HIT
    redirect "/game/dealer/stay"
  end  
  erb :game
end

get '/game/dealer/stay' do
  @show_hit_or_stay_buttons = false
  @show_hole_card = true
  session[:turn]  = "dealer"
  @gameover = true
  dealer_total = calculate_total(session[:dealer_cards])
  player_total = calculate_total(session[:player_cards])
  if dealer_total > player_total
    loser!("#{session[:player_name]} stayed at #{player_total}, and the dealer stayed at #{dealer_total}.")
  elsif dealer_total == player_total
    tie!("Both#{session[:player_name]} and the dealer stayed at #{player_total}.")
  else
    winner!("#{session[:player_name]} stayed at #{player_total} and the dealer stayed at #{dealer_total}.")
  end
  erb :game
end

get '/gameover' do
  session[:player_name] = nil
  erb :gameover
end
