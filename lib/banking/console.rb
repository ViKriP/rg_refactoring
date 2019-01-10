# frozen_string_literal: true

require 'yaml'
require 'pry'

module Banking
  class Console < ConsoleAccount
    attr_accessor :storage, :cashflow, :current_account, :card

    def initialize
      @current_account = Account.new
      @card = Card.new
      @storage = Storage.new
      @cashflow = CashFlow.new
      #@tax = Tax.new
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

        case gets.chomp
        when 'SC' then show_cards
        when 'CC' then create_card
        when 'DC' then destroy_card
        when 'PM' then put_money
        when 'WM' then withdraw_money
        when 'SM' then send_money
        when 'DA' then destroy_account
          #exit
        when 'exit' then exit
          break
        else
          puts "Wrong command. Try again!\n"
        end
      end
    end

    def show_cards
      @card.show_cards.each { |card| puts card }
    end

    def create_card
      loop do
        CREATE_CARD_MSG.each { |msg| puts msg }
        result_card_create = @card.create_card(gets.chomp)
        break unless result_card_create
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

        unless destroying[:error]
          @card.destroy_card(answer, gets.chomp)

          break if @card.card_deleted
          return unless @card.card_deleted
        end
      end
    end
  end
end
