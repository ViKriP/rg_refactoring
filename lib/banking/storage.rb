# frozen_string_literal: true

module Banking
  class Storage
    def load_data
      return [] unless File.exist?(DB_PATH)

      YAML.load_file(DB_PATH)
    end

    def save_data(data)
      File.open(DB_PATH, 'w') { |f| f.write data.to_yaml }
    end

    def update_data(current_account, change = false)
      new_accounts = []

      load_data.each do |account|

        if account.login == current_account.login
          new_accounts.push(current_account) if change
        else
          new_accounts.push(account)
        end
      end

      save_data(new_accounts)
    end

    def update_account(current_account)
      update_data(current_account, true)
    end

    def destroy_account(current_account)
      update_data(current_account)
    end

    def update_card_balance(card_number, card_balance)
      new_cards = []
      account = user_of_card(card_number)

      account.card.each do |card|
        card[:balance] = card_balance if card[:number] == card_number

        new_cards.push(card)
      end

      account.card = new_cards
      update_data(account, true)
    end

    def current_status_card(card)
      user_of_card(card[:number]).card.each do |card_base|
        return card if card_base[:number] == card[:number]
      end
    end

    def account_exists?(login)
      load_data.detect { |account_in_db| account_in_db.login == login }
    end

    def user_account(login, password)
      if load_data.map { |account| { login: account.login, password: account.password } }.include?({ login: login, password: password })
        { account: load_data.select { |usr| login == usr.login }.first, error: false }
      else
        { message: 'There is no account with given credentials', error: true }
      end
    end

    private

    def user_of_card(card_number)
      load_data.each do |account|
        if account.card.map { |card| card[:number] }.include? card_number

          account.card.each do |card|
            return account if card[:number] == card_number
          end
        end
      end
    end
  end
end
