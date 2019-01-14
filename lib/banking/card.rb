# frozen_string_literal: true

module Banking
  class Card
    include Constants

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
        cards.push(I18n.t(:no_cards))
      end
      cards
    end

    def create_card(card_type)
      if %w[usual capitalist virtual].include?(card_type)
        cards = @current_account.card << card_menu(card_type)
        @current_account.card = cards

        @storage.update_account(@current_account)

        false
      else
        I18n.t(:wrong_card_type)
      end
    end

    def destroy_card_list
      @card_any_exists = false

      return puts(I18n.t(:no_cards)) unless @current_account.card.any?

      cards_list_print = I18n.t(:want_to_delete)

      @current_account.card.each_with_index do |c, i|
        cards_list_print += "- #{c[:number]}, #{c[:type]}, press #{i + 1}" + "\n"
      end
      cards_list_print += I18n.t(:press_exit)
      @card_any_exists = true
      cards_list_print
    end

    def card_for_destroying(answer)
      if answer.to_i <= @current_account.card.length && answer.to_i.positive?
        { content: I18n.t(:sure_delete_card, card: @current_account.card[answer.to_i - 1][:number]),
          error: false }
      else
        { content: I18n.t(:wrong_number), error: true }
      end
    end

    def destroy_card(answer, delete_card)
      @card_deleted = false

      return unless delete_card == 'y'

      @current_account.card.delete_at(answer.to_i - 1)

      @storage.update_account(@current_account)

      @card_deleted = true
    end

    private

    def card_menu(card_type)
      case card_type
      when 'usual' then generate_card('usual', 50.00)
      when 'capitalist' then generate_card('capitalist', 100.00)
      when 'virtual' then generate_card('virtual', 150.00)
      end
    end

    def generate_card_number
      Array.new(CARD_NUMBER_LENGTH) { rand(NUMBERS_FOR_CARD) }.join
    end

    def generate_card(type_card, balans_card)
      { type: type_card, number: generate_card_number, balance: balans_card }
    end
  end
end
