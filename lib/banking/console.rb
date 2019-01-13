# frozen_string_literal: true

require 'yaml'
require 'pry'

module Banking
  class Console < ConsoleAccount
    include Constants

    attr_accessor :storage, :cashflow, :current_account, :card

    def initialize
      @current_account = Account.new
      @card = Card.new
      @storage = Storage.new
      @cashflow = CashFlow.new
    end

    def start
      HELLO_MSG.each { |msg| puts msg }

      case gets.chomp
      when 'create' then create
      when 'load' then load
      else exit
      end
    end

    def main_menu
      loop do
        puts "\nWelcome, #{@current_account.name}"
        MAIN_OPERATIONS_MSG.each { |msg| puts msg }

        command = gets.chomp

        exit if command == 'exit'

        next puts("Wrong command. Try again!\n") unless COMMAND_MENU[command]

        send(COMMAND_MENU[command])
      end
    end

    def show_cards
      @card.show_cards.each { |card| puts card }
    end

    def create_card
      loop do
        CREATE_CARD_MSG.each { |msg| puts msg }
        break unless result_card_create = @card.create_card(gets.chomp)

        puts result_card_create
      end
    end

    def destroy_card
      loop do
        puts @card.destroy_card_list
        break unless @card.card_any_exists

        answer = gets.chomp
        break if answer == 'exit'

        destroying = @card.card_for_destroying(answer)
        puts destroying[:content]

        return @card.destroy_card(answer, gets.chomp) unless destroying[:error]
      end
    end
  end
end
