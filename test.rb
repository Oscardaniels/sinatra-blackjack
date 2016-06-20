require "pry"
def card_converter(cards)
    hand_images = []
    cards.each do |card|
      card_image = ""
      case card.first
      when 'C'
        card_image += 'clubs_'
      when 'H'
        card_image += 'hearts_'
      when 'D'
        card_image += 'diamonds_'
      else 'S'
        card_image += 'spades_'       
      end
      binding.pry
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
      hand_images
      binding.pry
    end
  end

suits =['S', 'C', 'J', 'H']
values = [2, 3, 4, 5, 6, 7, 8, 9, 10, 'J', 'Q', 'K', 'A']
deck = suits.product(values).shuffle

hand = []
hand << deck.pop
hand << deck.pop 


puts card_converter(hand)