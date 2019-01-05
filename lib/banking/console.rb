# frozen_string_literal: true

require 'yaml'
require 'pry'

module Banking
  class Console
    attr_accessor :storage, :cashflow, :current_account, :tax, :card
                  #:login, :name, :password, :accounts, :account, 

    def initialize
      #@errors = []
      #@file_path = 'accounts.yml'
      @current_account = Account.new
      @current_account.card = []
      @card = Card.new
      #@account = Account.new
      #@account.card = []
      @storage = Storage.new
      #@card = Card.new(@current_account)
      @cashflow = CashFlow.new
      #puts @storage.accounts
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
      #puts "-TEST-"
      loop do
        name_input
        age_input
        login_input
        password_input
        #puts "-- #{@current_account.errors.length} --"
        #break unless @current_account.errors.length != 0
        break if @current_account.errors.empty?
        #puts "-- OK --"
        @current_account.errors.each do |e|
          puts e
        end
        @current_account.errors = []
      end
      
      #???????    @card = []
      #@account = Account.new
     # @current_account.name = @name
     # @current_account.login = @login
     # @current_account.password = @password      

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
=begin
        if @storage.accounts.map { |a| { login: a.login, password: a.password } }.include?({ login: login, password: password })
          a = @storage.accounts.select { |a| login == a.login }.first
          @current_account = a
          break
        else
          puts 'There is no account with given credentials'
          next
        end
=end         

        if accounts.map { |a| { login: a.login, password: a.password } }.include?({ login: login, password: password })
          @current_account = accounts.select { |usr| login == usr.login }.first
          break
        else
          puts 'There is no account with given credentials'
          next
        end
       
      end
      @card.current_account = @current_account
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
      #@card = Card.new(@current_account)
      #puts "#{@card.current_account} -- #{@current_account}"
      @card.show_cards1.each { |card| puts card }
=begin
      if @current_account.card.any?
        @current_account.card.each do |c|
          puts "- #{c[:number]}, #{c[:type]}"
        end
      else
        puts "There is no active cards!\n"
      end
=end      
    end

    def create_card
      #@card = Card.new(@current_account)
      #@card.create_card
      #puts "Ok ---- "
      loop do
        CREATE_CARD_MSG.each { |msg| puts msg }
        ct = gets.chomp
        #puts ct
        if %w[usual capitalist virtual].include?(ct)
          case ct
          when 'usual' then card = { type: 'usual', number: Array.new(16) { rand(10) }.join, balance: 50.00 }
          when 'capitalist' then card = { type: 'capitalist', number: Array.new(16) { rand(10) }.join, balance: 100.00 }
          when 'virtual' then card = { type: 'virtual', number: Array.new(16) { rand(10) }.join, balance: 150.00 }
          end
  
    #puts "++++++#{current_account.login} || #{current_account.card} || #{card}"
          cards = @current_account.card << card  #<< card #TODO more cards
          @current_account.card = cards
          new_accounts = []
      #puts "++++++#{@current_account.login} || #{@current_account.card} || #{card}"
      #puts "----- #{Storage.new.accounts}"
        accounts.each do |ac| #!!!! .accounts
          if ac.login == @current_account.login
            new_accounts.push(@current_account)
          else
            new_accounts.push(ac)
          end
          #puts "LOGINs ** #{ac.login} == #{@current_account.login}"
          #new_accounts.push(@current_account) if ac.login == @current_account.login
          #new_accounts.push(ac)
        end
          #cards #return card
          Storage.new.save_data(new_accounts)
          break
        else
          puts "Wrong card type. Try again!\n"
        end
      end
    end

    def destroy_card
      #@card = Card.new(@current_account)
      #@card.destroy_card

      loop do
        if @current_account.card.any?
          puts 'If you want to delete:'
  
          @current_account.card.each_with_index do |c, i|
            puts "- #{c[:number]}, #{c[:type]}, press #{i + 1}"
          end
          puts "press `exit` to exit\n"
          answer = gets.chomp
          break if answer == 'exit'
  
          if answer&.to_i.to_i <= @current_account.card.length && answer&.to_i.to_i.positive?
            puts "Are you sure you want to delete #{@current_account.card[answer&.to_i.to_i - 1][:number]}?[y/n]"
            if gets.chomp == 'y'
              @current_account.card.delete_at(answer&.to_i.to_i - 1)
              new_accounts = []
              @storage.load_data.each do |ac| #!!!accoumts
                if ac.login == @current_account.login
                  new_accounts.push(@current_account)
                else
                  new_accounts.push(ac)
                end
                #new_accounts.push(@current_account) if ac.login == @current_account.login
                #new_accounts.push(ac)
              end
              @storage.save_data(new_accounts)
              break
            else
              return
            end
          else
            puts "You entered wrong number!\n"
          end
        else
          puts "There is no active cards!\n"
          break
        end
      end
      
    end

    def withdraw_money
      #@cashflow.withdraw_money

      puts 'Choose the card for withdrawing:'
      answer, a2, a3 = nil
      if @current_account.card.any?
        @current_account.card.each_with_index do |c, i|
          puts "- #{c[:number]}, #{c[:type]}, press #{i + 1}"
        end
        puts "press `exit` to exit\n"
        loop do
          answer = gets.chomp
          break if answer == 'exit'
  
          if answer&.to_i.to_i <= @current_account.card.length && answer&.to_i.to_i.positive?
            current_card = @current_account.card[answer&.to_i.to_i - 1]
            loop do
              puts 'Input the amount of money you want to withdraw'
              a2 = gets.chomp
              if a2&.to_i.to_i.positive?
                money_left = current_card[:balance] - a2&.to_i.to_i - @tax.withdraw_tax(current_card[:type], current_card[:balance], current_card[:number], a2&.to_i.to_i)
                if money_left.positive?
                  current_card[:balance] = money_left
                  @current_account.card[answer&.to_i.to_i - 1] = current_card
                  new_accounts = []
                  @storage.accounts.each do |ac|
                    if ac.login == @current_account.login
                      new_accounts.push(@current_account)
                    else
                      new_accounts.push(ac)
                    end
                  end
                  @storage.save_data(new_accounts)
                  puts "Money #{a2&.to_i.to_i} withdrawed from #{current_card[:number]}$. Money left: #{current_card[:balance]}$. Tax: #{@tax.withdraw_tax(current_card[:type], current_card[:balance], current_card[:number], a2&.to_i.to_i)}$"
  
                  return
                else
                  puts "You don't have enough money on card for such operation"
                  return
                end
              else
                puts 'You must input correct amount of $'
                return
              end
            end
          else
            puts "You entered wrong number!\n"
            return
          end
        end
      else
        puts "There is no active cards!\n"
      end
    end

    def put_money
      #@cashflow.put_money

      puts 'Choose the card for putting:'

      if @current_account.card.any?
        @current_account.card.each_with_index do |c, i|
          puts "- #{c[:number]}, #{c[:type]}, press #{i + 1}"
        end
        puts "press `exit` to exit\n"
        loop do
          answer = gets.chomp
          break if answer == 'exit'
          
          if answer&.to_i.to_i <= @current_account.card.length && answer&.to_i.to_i.positive?
            current_card = @current_account.card[answer&.to_i.to_i - 1]
            loop do
              puts 'Input the amount of money you want to put on your card'
              a2 = gets.chomp
              if a2&.to_i.to_i.positive?
                if @tax.put_tax(current_card[:type], current_card[:balance], current_card[:number], a2&.to_i.to_i) >= a2&.to_i.to_i
                  puts 'Your tax is higher than input amount'
                  return
                else
                  new_money_amount = current_card[:balance] + a2&.to_i.to_i - @tax.put_tax(current_card[:type], current_card[:balance], current_card[:number], a2&.to_i.to_i)
                  current_card[:balance] = new_money_amount
                  @current_account.card[answer&.to_i.to_i - 1] = current_card
                  new_accounts = []
                  accounts.each do |ac|
                    if ac.login == @current_account.login
                      new_accounts.push(@current_account)
                    else
                      new_accounts.push(ac)
                    end
                  end
                  @storage.save_data(new_accounts)
                  puts "Money #{a2&.to_i.to_i} was put on #{current_card[:number]}. Balance: #{current_card[:balance]}. Tax: #{@tax.put_tax(current_card[:type], current_card[:balance], current_card[:number], a2&.to_i.to_i)}"
                  return
                end
              else
                puts 'You must input correct amount of money'
                return
              end
            end
          else
            puts "You entered wrong number!\n"
            return
          end
        end
      else
        puts "There is no active cards!\n"
      end
    end

    def send_money
      #@cashflow.send_money

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
      all_cards = @storage.accounts.map(&:card).flatten
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
        elsif put_tax(recipient_card[:type], recipient_card[:balance], recipient_card[:number], a3&.to_i.to_i) >= a3&.to_i.to_i
          puts 'There is no enough money on sender card'
        else
          sender_card[:balance] = sender_balance
          @current_account.card[answer&.to_i.to_i - 1] = sender_card
          new_accounts = []
          @storage.accounts.each do |ac|
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
      #puts "=== #{accounts}"
      @current_account.destroy_account(gets.chomp)
      
=begin    
      if gets.chomp == 'y'
        new_accounts = []
        accounts.each do |ac|
          if ac.login == @current_account.login
          else
            new_accounts.push(ac)
          end
        end
        @storage.save_data(new_accounts)
      end
=end      
    end

    private
  
    def name_input
      puts 'Enter your name'
      #@account.name = gets.chomp
      #name = gets.chomp
      #@account.name_input(name)

      @current_account.name_input(gets.chomp)

      #@name = gets.chomp
      #if @name.empty? || @name[0].upcase != @name[0]
      #  @errors.push('Your name must not be empty and starts with first upcase letter')
      #end
    end

    def login_input
      puts 'Enter your login'
      #login = gets.chomp
      #@account.login_input(login)

      @current_account.login_input(gets.chomp)

      #@login = gets.chomp
      #@errors.push('Login must present') if @login.empty?
      #@errors.push('Login must be longer then 4 symbols') if @login.length < 4
      #@errors.push('Login must be shorter then 20 symbols') if @login.length > 20
      #@errors.push('Such account is already exists') if accounts.map(&:login).include?(@login)
    end

    def password_input
      puts 'Enter your password'
      #psw = gets.chomp
      #@account.password_input(psw)

      @current_account.password_input(gets.chomp)

      #@password = gets.chomp
      #@errors.push('Password must present') if @password.empty?
      #@errors.push('Password must be longer then 6 symbols') if @password.length < 6
      #@errors.push('Password must be shorter then 30 symbols') if @password.length > 30
    end

    def age_input
      puts 'Enter your age'
      #age = gets.chomp
      #@account.age_input(age)

      @current_account.age_input(gets.chomp)

      #@age = gets.chomp
      #if @age.to_i.is_a?(Integer) && @age.to_i >= 23 && @age.to_i <= 90
      #  @age = @age.to_i
      #else
      # @errors.push('Your Age must be greeter then 23 and lower then 90')
      #end
    end

    def accounts
      @storage.load_data
    end
  end
end
