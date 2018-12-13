# frozen_string_literal: true

require 'yaml'
require 'pry'

module Banking
class Account
  include Storage
  include Card
  include Cash_flow
  include Tax
  attr_accessor :login, :name, :card, :password, :file_path

  def initialize
    @errors = []
    @file_path = 'accounts.yml'
  end

  def console
      puts 'Hello, we are RubyG bank!'
      puts '- If you want to create account - press `create`'
      puts '- If you want to load account - press `load`'
      puts '- If you want to exit - press `exit`'

    # FIRST SCENARIO. IMPROVEMENT NEEDED

    a = gets.chomp

    if a == 'create'
      create
    elsif a == 'load'
      load
    else
      exit
    end
  end

  def create
    loop do
      name_input
      age_input
      login_input
      password_input
      break unless @errors.length != 0
      @errors.each do |e|
        puts e
      end
      @errors = []
    end

    @card = []
    new_accounts = accounts << self
    @current_account = self
    File.open(@file_path, 'w') { |f| f.write new_accounts.to_yaml } #Storing
    main_menu
  end

  def load
    loop do
      if !accounts.any?
        return create_the_first_account
      end

      puts 'Enter your login'
      login = gets.chomp
      puts 'Enter your password'
      password = gets.chomp

      if accounts.map { |a| { login: a.login, password: a.password } }.include?({ login: login, password: password })
        a = accounts.select { |usr| login == usr.login }.first
        @current_account = a
        break
      else
        puts 'There is no account with given credentials'
        next
      end
    end
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
      puts 'If you want to:'
      puts '- show all cards - press SC'
      puts '- create card - press CC'
      puts '- destroy card - press DC'
      puts '- put money on card - press PM'
      puts '- withdraw money on card - press WM'
      puts '- send money to another card  - press SM'
      puts '- destroy account - press `DA`'
      puts '- exit from account - press `exit`'

      command = gets.chomp

      if command == 'SC' || command == 'CC' || command == 'DC' || command == 'PM' || command == 'WM' || command == 'SM' || command == 'DA' || command == 'exit'
        if command == 'SC'
          show_cards
        elsif command == 'CC'
          create_card
        elsif command == 'DC'
          destroy_card
        elsif command == 'PM'
          put_money
        elsif command == 'WM'
          withdraw_money
        elsif command == 'SM'
          send_money
        elsif command == 'DA'
          destroy_account
          exit
        elsif command == 'exit'
          exit
          break
        end
      else
        puts "Wrong command. Try again!\n"
      end
    end
  end


  def destroy_account
    puts 'Are you sure you want to destroy account?[y/n]'
    a = gets.chomp
    if a == 'y'
      new_accounts = []
      accounts.each do |ac|
        if ac.login == @current_account.login
        else
          new_accounts.push(ac)
        end
      end
      File.open(@file_path, 'w') { |f| f.write new_accounts.to_yaml } #Storing
    end
  end

  private

  def name_input
    puts 'Enter your name'
    @name = gets.chomp
    unless @name != '' && @name[0].upcase == @name[0]
      @errors.push('Your name must not be empty and starts with first upcase letter')
    end
  end

  def login_input
    puts 'Enter your login'
    @login = gets.chomp
    if @login == ''
      @errors.push('Login must present')
    end

    if @login.length < 4
      @errors.push('Login must be longer then 4 symbols')
    end

    if @login.length > 20
      @errors.push('Login must be shorter then 20 symbols')
    end

    if accounts.map { |a| a.login }.include? @login
      @errors.push('Such account is already exists')
    end
  end

  def password_input
    puts 'Enter your password'
    @password = gets.chomp
    if @password == ''
      @errors.push('Password must present')
    end

    if @password.length < 6
      @errors.push('Password must be longer then 6 symbols')
    end

    if @password.length > 30
      @errors.push('Password must be shorter then 30 symbols')
    end
  end

  def age_input
    puts 'Enter your age'
    @age = gets.chomp
    if @age.to_i.is_a?(Integer) && @age.to_i >= 23 && @age.to_i <= 90
      @age = @age.to_i
    else
      @errors.push('Your Age must be greeter then 23 and lower then 90')
    end
  end

 
end
end
