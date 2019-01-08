# frozen_string_literal: true

module Banking
  class Card
    attr_accessor :storage, :current_account, :card_any_exists, :card_deleted

    def initialize
      @current_account = Account.new
      @storage = Storage.new
    end

    def show_cards
      cards = []
      if @current_account.card.any?
        @current_account.card.each do |c|
          cards.push("- #{c[:number]}, #{c[:type]}")
        end
      else
        cards.push("There is no active cards!\n")
      end
      cards
    end

    def create_card(card_type)
      if %w[usual capitalist virtual].include?(card_type)
        case card_type
        when 'usual' then card = { type: 'usual', number: Array.new(16) { rand(10) }.join, balance: 50.00 }
        when 'capitalist' then card = { type: 'capitalist', number: Array.new(16) { rand(10) }.join, balance: 100.00 }
        when 'virtual' then card = { type: 'virtual', number: Array.new(16) { rand(10) }.join, balance: 150.00 }
        end

        cards = @current_account.card << card
        @current_account.card = cards

        @storage.update_data(@current_account)

        false
      else
        "Wrong card type. Try again!\n"
      end
    end

    def destroy_card_list
      @card_any_exists = false
      if @current_account.card.any?
        cards_list_print = "If you want to delete:\n"

        @current_account.card.each_with_index do |c, i|
          cards_list_print += "- #{c[:number]}, #{c[:type]}, press #{i + 1}" + "\n"
        end
        cards_list_print += "press `exit` to exit\n"
        @card_any_exists = true
        cards_list_print
      else
        "There is no active cards!\n"
      end
    end

    def card_for_destroying(answer)
      if answer&.to_i.to_i <= @current_account.card.length && answer&.to_i.to_i.positive?
        { content: "Are you sure you want to delete #{@current_account.card[answer&.to_i.to_i - 1][:number]}?[y/n]",
                    error: false }
      else
        { content: "You entered wrong number!\n", error: true }
      end
    end

    def destroy_card(answer, delete_card)
      @card_deleted = false
      if delete_card == 'y'
        @current_account.card.delete_at(answer&.to_i.to_i - 1)

        @storage.update_data(@current_account)

        @card_deleted = true
      end
    end
  end
end
