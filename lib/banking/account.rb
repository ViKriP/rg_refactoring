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
      @errors.push(I18n.t(:invalid_name)) if @name.empty? || @name[0].upcase != @name[0]
    end

    def login_input(login)
      @login = login
      @errors.push(I18n.t(:login_empty)) if @login.empty?
      @errors.push(I18n.t(:login_too_short)) if @login.length < 4
      @errors.push(I18n.t(:login_too_long)) if @login.length > 20
      @errors.push(I18n.t(:account_exists)) if @storage.account_exists?(@login)
    end

    def password_input(password)
      @password = password
      @errors.push(I18n.t(:password_empty)) if @password.empty?
      @errors.push(I18n.t(:password_too_short)) if @password.length < 6
      @errors.push(I18n.t(:password_too_long)) if @password.length > 30
    end

    def age_input(age)
      @age = age
      @errors.push(I18n.t(:invalid_age)) unless (23..89).cover?(@age.to_i)
    end
  end
end
