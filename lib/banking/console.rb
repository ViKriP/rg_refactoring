# frozen_string_literal: true

require 'yaml'
require 'pry'

module Banking
  class Console
    attr_accessor :storage, :cashflow, :current_account, :card#, :tax

    def initialize
      @current_account = Account.new
      @current_account.card = []
      @card = Card.new
      @storage = Storage.new
      @cashflow = CashFlow.new
      @tax = Tax.new
    end

    def console
      HELLO_MSG.each { |msg| puts msg }

      case gets.chomp
        when 'create' then create
        when 'load' then load
          else exit
      end
    end

    def create
      loop do
        name_input
        age_input
        login_input
        password_input

        break if @current_account.errors.empty?

        @current_account.errors.each do |e|
          puts e
        end
        @current_account.errors = []
      end
      
      new_accounts = accounts << @current_account #self # TODO self to Account
      #@current_account = @current_account #self
      #@card.current_account = @current_account
      @card.current_account = @current_account
      @cashflow.current_account = @current_account
      @storage.save_data(new_accounts)
      main_menu
    end

    def load
      loop do
        if !accounts.any?
          return create_the_first_account
        end
        #return create_the_first_account if !@storage.accounts.any?
  
        puts 'Enter your login'
        login = gets.chomp
        puts 'Enter your password'
        password = gets.chomp

        if accounts.map { |a| { login: a.login, password: a.password } }.include?({ login: login, password: password })
          @current_account = accounts.select { |usr| login == usr.login }.first
          break
        else
          puts 'There is no account with given credentials'
          next
        end
       
      end
      @card.current_account = @current_account
      @cashflow.current_account = @current_account
      main_menu
    end

    def create_the_first_account
      puts 'There is no active accounts, do you want to be the first?[y/n]'
      if gets.chomp == 'y'
        return create
      else
        return console
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
          exit
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
        res = @card.create_card(gets.chomp)
        break unless res 
          puts res
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
          return unless @card.card_deleted #TODO del
        end
      end
    end

    def withdraw_money
      puts "Choose the card for withdrawing:\n"
      puts @cashflow.cards_list

      loop do
        answer = gets.chomp
        break if answer == 'exit'

        card_selection = @cashflow.card_selection(answer)

        if card_selection[:error]
          puts card_selection[:message]
          return 
        end
        current_card = card_selection[:current_card]

        loop do
          puts 'Input the amount of money you want to withdraw'
          a2 = gets.chomp

          amount = @cashflow.correct_amount(a2)

          if amount[:error]
            puts amount[:message]
            return
          end

          withdrawing_finality = @cashflow.withdraw_money(current_card, a2, answer)

          if withdrawing_finality[:return]
            puts withdrawing_finality[:message]
            return
          end
        end
      end
    end

    def put_money
      puts 'Choose the card for putting:'
      puts @cashflow.cards_list

      loop do
        answer = gets.chomp
        break if answer == 'exit'

        card_selection = @cashflow.card_selection(answer)

        if card_selection[:error]
          puts card_selection[:message]
          return 
        end
        current_card = card_selection[:current_card]

        loop do
          puts 'Input the amount of money you want to put on your card'
          a2 = gets.chomp

          amount = @cashflow.correct_amount(a2)

          if amount[:error]
            puts amount[:message]
            return
          end

          puts @cashflow.put_money(current_card, a2, answer)
          return
        end
      end
    end

    def send_money
      puts 'Choose the card for sending:'

      puts @cashflow.cards_list
      return unless @cashflow.card_any_exists
      #puts @cashflow.cards_list

      answer = gets.chomp
      exit if answer == 'exit'

      card_selection = @cashflow.card_selection(answer)

      if card_selection[:error]
        puts card_selection[:message]
        return 
      end
      sender_card = card_selection[:current_card]

      puts 'Enter the recipient card:'
      a2 = gets.chomp

      recipient_card = @cashflow.recipient_card_get(a2)
      if recipient_card[:error]
        puts recipient_card[:message]
        return 
      end

      recipient_card = recipient_card[:recipient_card]

      loop do
        puts 'Input the amount of money you want to withdraw'
        a3 = gets.chomp

        card_balance = @cashflow.card_balance(a3, sender_card, recipient_card)
        if card_balance[:error]
          puts card_balance[:message]
          return #TODO ???
        end
        sender_balance = card_balance[:sender_balance]
        recipient_balance = card_balance[:recipient_balance]

        dd = @cashflow.send_money(a3, a2, answer, sender_card, recipient_card, sender_balance, recipient_balance)
        puts dd[:message]
        break unless dd[:error]
      end

    end

=begin
    def send_money_
      puts 'Choose the card for sending:'

      if @current_account.card.any?
        @current_account.card.each_with_index do |c, i|
          puts "- #{c[:number]}, #{c[:type]}, press #{i + 1}"
        end
        puts "press `exit` to exit\n"
  
        answer = gets.chomp
        exit if answer == 'exit'
  
        if answer&.to_i.to_i <= @current_account.card.length && answer&.to_i.to_i.positive?
          sender_card = @current_account.card[answer&.to_i.to_i - 1]
        else
          puts 'Choose correct card'
          return
        end
      else
        puts "There is no active cards!\n"
        return
      end

      puts 'Enter the recipient card:'
      a2 = gets.chomp
      if a2.length > 15 && a2.length < 17
        all_cards = @storage.load_data.map(&:card).flatten
        if all_cards.select { |card| card[:number] == a2 }.any?
          recipient_card = all_cards.select { |card| card[:number] == a2 }.first
        else
          puts "There is no card with number #{a2}\n"
          return
        end
      else
        puts 'Please, input correct number of card'
        return
      end

      loop do
        puts 'Input the amount of money you want to withdraw'
        a3 = gets.chomp

        if a3&.to_i.to_i.positive?
          sender_balance = sender_card[:balance] - a3&.to_i.to_i - @tax.sender_tax(sender_card[:type], sender_card[:balance], sender_card[:number], a3&.to_i.to_i)
          recipient_balance = recipient_card[:balance] + a3&.to_i.to_i - @tax.put_tax(recipient_card[:type], recipient_card[:balance], recipient_card[:number], a3&.to_i.to_i)
  
          if sender_balance.negative?
            puts "You don't have enough money on card for such operation"
          elsif @tax.put_tax(recipient_card[:type], recipient_card[:balance], recipient_card[:number], a3&.to_i.to_i) >= a3&.to_i.to_i
            puts 'There is no enough money on sender card'
          else
            sender_card[:balance] = sender_balance
            @current_account.card[answer&.to_i.to_i - 1] = sender_card
            new_accounts = []
            accounts.each do |ac|
              if ac.login == @current_account.login
                new_accounts.push(@current_account)
              elsif ac.card.map { |card| card[:number] }.include? a2
                recipient = ac
                new_recipient_cards = []
                recipient.card.each do |card|
                  card[:balance] = recipient_balance if card[:number] == a2
                  new_recipient_cards.push(card)
                end
                recipient.card = new_recipient_cards
                new_accounts.push(recipient)
              end
            end
            @storage.save_data(new_accounts)
            puts "Money #{a3&.to_i.to_i}$ was put on #{sender_card[:number]}. Balance: #{recipient_balance}. Tax: #{@tax.put_tax(sender_card[:type], sender_card[:balance], sender_card[:number], a3&.to_i.to_i)}$\n"
            puts "Money #{a3&.to_i.to_i}$ was put on #{a2}. Balance: #{sender_balance}. Tax: #{@tax.sender_tax(sender_card[:type], sender_card[:balance], sender_card[:number], a3&.to_i.to_i)}$\n"
            break
          end
        else
          puts 'You entered wrong number!\n'
        end
      end
    
    end
=end
    #def withdraw_tax(type, _balance, _number, amount)
    #  @tax.withdraw_tax(type, _balance, _number, amount)
    #end

    #def put_tax(type, _balance, _number, amount)
    #  @tax.put_tax(type, _balance, _number, amount)
    #end

    #def sender_tax(type, _balance, _number, amount)
    #  @tax.sender_tax(type, _balance, _number, amount)
    #end

    #def accounts
    #  @storage.accounts
    #end

    def destroy_account
      puts 'Are you sure you want to destroy account?[y/n]'
      @current_account.destroy_account(gets.chomp)
    end

    private
  
    def name_input
      puts 'Enter your name'
      @current_account.name_input(gets.chomp)
    end

    def login_input
      puts 'Enter your login'
      @current_account.login_input(gets.chomp)
    end

    def password_input
      puts 'Enter your password'
      @current_account.password_input(gets.chomp)
    end

    def age_input
      puts 'Enter your age'
      @current_account.age_input(gets.chomp)
    end

    def accounts
      @storage.load_data
    end
  end
end
