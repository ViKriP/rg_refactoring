# frozen_string_literal: true

module Banking
  class ConsoleAccount < ConsoleCashFlow
    def create
      loop do
        registration_data

        break if @current_account.errors.empty?

        @current_account.errors = []
      end

      new_accounts = @storage.load_data << @current_account
      @storage.save_data(new_accounts)

      current_account_update(@current_account)

      main_menu
    end

    def load
      return create_the_first_account unless @storage.load_data.any?

      loop do
        account = login_in

        break @current_account = account[:account] unless account[:error]

        puts(account[:message])
        next
      end

      current_account_update(@current_account)

      main_menu
    end

    def create_the_first_account
      puts I18n.t(:no_accounts)

      gets.chomp == 'y' ? create : start
    end

    def destroy_account
      puts I18n.t(:sure_delete_account)

      exit @storage.destroy_account(@current_account) if gets.chomp == 'y'
    end

    private

    def registration_data
      name_input
      age_input
      login_input
      password_input

      return if @current_account.errors.empty?

      @current_account.errors.each { |error| puts error }
    end

    def name_input
      puts I18n.t(:enter_name)
      @current_account.name_input(gets.chomp)
    end

    def login_input
      puts I18n.t(:enter_login)
      @current_account.login_input(gets.chomp)
    end

    def password_input
      puts I18n.t(:enter_password)
      @current_account.password_input(gets.chomp)
    end

    def age_input
      puts I18n.t(:enter_age)
      @current_account.age_input(gets.chomp)
    end

    def login_in
      puts I18n.t(:enter_login)
      login = gets.chomp
      puts I18n.t(:enter_password)
      password = gets.chomp

      @storage.user_account(login, password)
    end
  end
end
