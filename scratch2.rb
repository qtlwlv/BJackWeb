require 'rubygems'
require 'pry'

hand = [["H", "5"], ["D", "A"]]
def jpgcard(hand)
    arr0 = hand.map{|suit| suit[0]}

    result_array = []
    arr0.each do |suit|
      if suit == "H"
        result_array << "hearts_"
      elsif suit == "C"
        result_array << "clubs_"
      elsif suit == "D"
        result_array << "diamonds_"
      elsif suit == "S"
        result_array << "spades_"
      end
    end
    result_array

    arr1 = hand.map{|face| face [1]}

    result = []
    arr1.each do |face|
      if face == "A"
        result << "ace.jpg"
      elsif face == "K"
        result << "king.jpg"
      elsif face == "Q"
        result << "queen.jpg"
      elsif face == "J"
        result << "jack.jpg"
      else face
        result << face.to_s + ".jpg"
      end
    end
    result

  jpg = result_array.map{|n| result[n]}
  jpg
end

jpgcard(hand)
puts arr0



 arr0 = hand.map{|suit| suit[0]}

    arr0.each do |suit|
      if suit == "H"
        "hearts_"
      elsif suit == "C"
        "clubs_"
      elsif suit == "D"
        "diamonds_"
      elsif suit == "S"
        "spades_"
      end
    end

    arr1 = hand.map{|face| face[1]}

    arr1.each do |face|
      if face == "A"
        "ace.jpg"
      elsif face == "K"
        "king.jpg"
      elsif face == "Q"
        "queen.jpg"
      elsif face == "J"
        "jack.jpg"
      else face
        face.replace face.to_s + ".jpg"
      end
    end

    arr2 = hand.map{|jpg| jpg[0]+jpg[1]}


<% session[:d_hand].each_with_index do |card, i| %>
    <% if session[:turn] != "dealer" && i == 0 %>
      <img src="/images/cards/cover.jpg" class="jpgcard">
    <% else %>
      <%= jpgcard(card) %>
    <%end %>
