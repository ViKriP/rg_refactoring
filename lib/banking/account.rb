# frozen_string_literal: true

require 'yaml'
require 'pry'

module Banking
  class Account
    include Console
    include Storage
    include Card
    include CashFlow
    include Tax
    attr_accessor :login, :name, :card, :password, :file_path

    def initialize
      @errors = []
      @file_path = '../../accounts.yml'
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
      save_data(@file_path, new_accounts)
      main_menu
    end

    def load
      loop do
        return create_the_first_account if !accounts.any?
  
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

    def destroy_account
      puts 'Are you sure you want to destroy account?[y/n]'
      if gets.chomp == 'y'
        new_accounts = []
        accounts.each do |ac|
          if ac.login == @current_account.login
          else
            new_accounts.push(ac)
          end
        end
        save_data(@file_path, new_accounts)
      end
    end

    private
  
    def name_input
      puts 'Enter your name'
      @name = gets.chomp
      if @name.empty? || @name[0].upcase != @name[0]
        @errors.push('Your name must not be empty and starts with first upcase letter')
      end
    end

    def login_input
      puts 'Enter your login'
      @login = gets.chomp
      @errors.push('Login must present') if @login.empty?
      @errors.push('Login must be longer then 4 symbols') if @login.length < 4
      @errors.push('Login must be shorter then 20 symbols') if @login.length > 20
      @errors.push('Such account is already exists') if accounts.map(&:login).include?(@login)
    end

    def password_input
      puts 'Enter your password'
      @password = gets.chomp
      @errors.push('Password must present') if @password.empty?
      @errors.push('Password must be longer then 6 symbols') if @password.length < 6
      @errors.push('Password must be shorter then 30 symbols') if @password.length > 30
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
