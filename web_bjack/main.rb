require 'rubygems'
require 'sinatra'


set :sessions, true

BLACKJACK = 21
DEALER_MIN_STAY = 17
PLAYER_POT = 500

helpers do
  def total(hand)
    arr = hand.map{|face| face[1]}

    total = 0
    arr.each do |face|
      if face == "A"
        total += 11
      elsif face.to_i == 0
        total += 10
      else
        total += face.to_i
      end
    end

    arr.select{|face| face == "A"}.count.times do
      total -= 10 if total > BLACKJACK
    end

    total
  end


  def jpgcard(card)
    suit = case card [0]
      when 'H' then 'hearts'
      when 'D' then 'diamonds'
      when 'C' then 'clubs'
      when 'S' then 'spades'
    end

    face = card [1]
    if ['J', 'Q', 'K', 'A'].include?(face)
      face = case card[1]
        when 'J' then 'jack'
        when 'Q' then 'queen'
        when 'K' then 'king'
        when 'A' then 'ace'
      end
    end

    "<img src='/images/cards/#{suit}_#{face}.jpg' class='jpgcard'>"
  end


  def win(msg)
    @show_hit_or_stay_buttons = false
    @hand_compare = true
    @show_play_again_or_exit_buttons = true
    session[:player_pot] = session[:player_pot] + session[:player_bet]
    @success = "Winner! #{msg}"
  end


  def lost(msg)
    @show_hit_or_stay_buttons = false
    @hand_compare = true
    @show_play_again_or_exit_buttons = true
    session[:player_pot] = session[:player_pot] - session[:player_bet]
    @error = "Lost. #{msg}"
  end


  def push(msg)
    @show_hit_or_stay_buttons = false
    @hand_compare = true
    @show_play_again_or_exit_buttons = true
    @success = "Its a push! #{msg}"
  end
end


before do
  @show_hit_or_stay_buttons = true
  @show_play_again_or_exit_buttons = false
  @hand_compare = false
end

get '/' do
  if session[:player_name]
    redirect '/game'
  else
    redirect '/new_player'
  end
end

get '/new_player' do
  session[:player_pot] = PLAYER_POT
  erb :new_player
end

post '/new_player' do
  if params[:player_name].empty?
    @error = "Please tell us your name."
    halt erb(:new_player)
  end
  session[:player_name] = params[:player_name].capitalize
  redirect '/bet'
end

get '/bet' do
  if session[:player_pot] == 0
    redirect '/game_over'
  else
    session[:player_bet] = nil
  end
  erb :bet
end

post '/bet' do
  if params[:bet_amount].nil? || params[:bet_amount].to_i == 0
    @error = "You cant win if you don't bet.  Please place your bet."
    halt erb(:bet)
  elsif params[:bet_amount].to_i > session[:player_pot]
    @error = "Sorry, no loans here. Bet amount cannot be greater than what you have: ($#{session[:player_pot]}"
    halt erb(:bet)
  else
    session[:player_bet] = params[:bet_amount].to_i
    redirect '/game'
  end
end

get '/game' do
  session[:turn] = session[:player_name]

  suit = ['H', 'D', 'C', 'S']
  face = ['2', '3', '4', '5', '6', '7', '8', '9', 'J', 'Q', 'K', 'A']
  session[:deck] = suit.product(face).shuffle!

  session[:d_hand] = Array.new
  session[:p_hand] = Array.new

  session[:d_hand] << session[:deck].pop
  session[:p_hand] << session[:deck].pop
  session[:d_hand] << session[:deck].pop
  session[:p_hand] << session[:deck].pop

  if total(session[:p_hand]) == BLACKJACK and total(session[:d_hand]) == BLACKJACK
    session[:turn] = "dealer"
    push("Both #{session[:player_name]} and the Dealer have BlackJack!")
  elsif total(session[:p_hand]) == BLACKJACK
    session[:turn] = "dealer"
    win("#{session[:player_name]} hit BlackJack!")
    session[:player_pot] = session[:player_pot] + 0.5 * session[:player_bet]
  elsif total(session[:d_hand]) == BLACKJACK
    session[:turn] = "dealer"
    lost("Dealer hit BlackJack.")
  end

  erb :game
end


post '/game/player/hit' do
  session[:p_hand] << session[:deck].pop
  if total(session[:p_hand]) == BLACKJACK
    @success = "Congratuations! #{session[:player_name]} has 21! I'll assume your staying."
    @show_play_again_or_exit_buttons = false
    redirect '/game/dealer'
  elsif
    total(session[:p_hand]) > BLACKJACK
    lost("#{session[:player_name]} busted with #{total(session[:p_hand])}.")
  end

  erb :game
end


post '/game/player/stay' do
  @success = "#{session[:player_name]} has chosen to stay."
  @show_hit_or_stay_buttons = false
  redirect '/game/dealer'
  erb :game
end


get '/game/dealer' do
  session[:turn] = "dealer"

  @show_hit_or_stay_buttons = false
  @hand_compare = true
  while true
    if total(session[:d_hand]) < DEALER_MIN_STAY
      session[:d_hand] << session[:deck].pop
      @hand_compare = true
    elsif total(session[:d_hand]) > BLACKJACK
      @success = "Dealer Busts! You Win!"
      @show_play_again_or_exit_buttons = true
      break
    else
      break
    end
  end

  redirect '/game/hand_compare'
  erb :game
end


get '/game/hand_compare' do
    if total(session[:d_hand]) > BLACKJACK
      win("Dealer Busts! #{session[:player_name]} wins with #{total(session[:p_hand])}.")
    elsif total(session[:d_hand]) > total(session[:p_hand])
      lost("Dealer wins with #{total(session[:d_hand])}, #{session[:player_name]} has #{total(session[:p_hand])}.")
    elsif total(session[:d_hand]) == total(session[:p_hand])
      push("Both Dealer and #{session[:player_name]} have #{total(session[:p_hand])}.")
    else
      win("#{session[:player_name]} wins with #{total(session[:p_hand])}, Dealer has #{total(session[:d_hand])}.")
    end

  erb :game
end


get '/game_over' do
  erb :game_over
end
