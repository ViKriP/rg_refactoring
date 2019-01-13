# frozen_string_literal: true

module Banking
  class Account
    attr_accessor :name, :login, :password, :age, :storage, :errors, :card

    def initialize
      @errors = []
      @card = []
      @storage = Storage.new
    end

    def name_input(name)
      @name = name
      if @name.empty? || @name[0].upcase != @name[0]
        @errors.push('Your name must not be empty and starts with first upcase letter')
      end
    end

    def login_input(login)
      @login = login
      @errors.push('Login must present') if @login.empty?
      @errors.push('Login must be longer then 4 symbols') if @login.length < 4
      @errors.push('Login must be shorter then 20 symbols') if @login.length > 20
      @errors.push('Such account is already exists') if @storage.account_exists?(@login)
    end

    def password_input(password)
      @password = password
      @errors.push('Password must present') if @password.empty?
      @errors.push('Password must be longer then 6 symbols') if @password.length < 6
      @errors.push('Password must be shorter then 30 symbols') if @password.length > 30
    end

    def age_input(age)
      @age = age
      if @age.to_i.is_a?(Integer) && @age.to_i >= 23 && @age.to_i <= 90
        @age = @age.to_i
      else
        @errors.push('Your Age must be greeter then 23 and lower then 90')
      end
    end
  end
end
