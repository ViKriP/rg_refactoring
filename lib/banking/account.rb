# frozen_string_literal: true

module Banking
  class Account
    attr_accessor :name, :login, :password, :age, :storage, :errors, :card

    def initialize
      @errors = []
      @card = []
      @storage = Storage.new
    end

    def destroy_account(del_y)
      #puts 'Are you sure you want to destroy account?[y/n]'
      #puts "#{@storage.file_path} - storage.file_path"
      #puts "== #{del_y} == #{@storage.load_data}"
      if del_y == 'y'
        new_accounts = []
        @storage.load_data.each do |ac| #accounts
#        @storage.load_data.each do |ac|
          if ac.login == @login
          else
            new_accounts.push(ac)
          end
        end
        @storage.save_data(new_accounts)
      end
    end

    def name_input(name)
      @name = name
      if @name.empty? || @name[0].upcase != @name[0]
        @errors.push('Your name must not be empty and starts with first upcase letter')
      end
      #puts "#{@name} -- #{@errors}"
    end

    def login_input(login)
      #puts 'Enter your login'
      #puts "-- #{login} -- #{account_exists?} -- "
      @login = login
      @errors.push('Login must present') if @login.empty?
      @errors.push('Login must be longer then 4 symbols') if @login.length < 4
      @errors.push('Login must be shorter then 20 symbols') if @login.length > 20
      #puts "-------------- #{@storage.load_data} -- #{Banking::DB_PATH}"
      @errors.push('Such account is already exists') if account_exists?# @storage.load_data.map(&:login).include?(@login)
    end

    def password_input(password)
      #puts 'Enter your password'
      @password = password
      @errors.push('Password must present') if @password.empty?
      @errors.push('Password must be longer then 6 symbols') if @password.length < 6
      @errors.push('Password must be shorter then 30 symbols') if @password.length > 30
    end

    def age_input(age)
      #puts 'Enter your age'
      @age = age
      if @age.to_i.is_a?(Integer) && @age.to_i >= 23 && @age.to_i <= 90
        @age = @age.to_i
      else
        @errors.push('Your Age must be greeter then 23 and lower then 90')
      end
    end

    def account_exists?
      #puts "-- #{@storage.load_data}"
      @storage.load_data.detect { |account_in_db| account_in_db.login == @login }
    end

=begin
    def name_input(name)
      #puts 'Enter your name'
      @name = name
      if @name.empty? || @name[0].upcase != @name[0]
        @errors.push('Your name must not be empty and starts with first upcase letter')
      end
    end

    def login_input(login)
      #puts 'Enter your login'
      @login = login
      @errors.push('Login must present') if @login.empty?
      @errors.push('Login must be longer then 4 symbols') if @login.length < 4
      @errors.push('Login must be shorter then 20 symbols') if @login.length > 20
      puts "-------------- #{@storage.accounts}"
      @errors.push('Such account is already exists') if @storage.accounts.map(&:login).include?(@login)
    end

    def password_input(psw)
      #puts 'Enter your password'
      @password = psw
      @errors.push('Password must present') if @password.empty?
      @errors.push('Password must be longer then 6 symbols') if @password.length < 6
      @errors.push('Password must be shorter then 30 symbols') if @password.length > 30
    end

    def age_input(age)
      #puts 'Enter your age'
      @age = age
      if @age.to_i.is_a?(Integer) && @age.to_i >= 23 && @age.to_i <= 90
        @age = @age.to_i
      else
        @errors.push('Your Age must be greeter then 23 and lower then 90')
      end
    end
=end    
  end
end
