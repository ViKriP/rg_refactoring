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

    def update_data(current_account)
      new_accounts = []
      load_data.each do |ac|
        if ac.login == current_account.login
          new_accounts.push(current_account)
        else
          new_accounts.push(ac)
        end
      end
      save_data(new_accounts)
    end

    def update_card_balance(card_number, card_balance)
      load_data.each do |ac|
        if ac.card.map { |card| card[:number] }.include? card_number
          new_cards = []
          ac.card.each do |card|
            card[:balance] = card_balance if card[:number] == card_number
            new_cards.push(card)
          end
          ac.card = new_cards
          update_data(ac)
        end
      end
    end

    def account_exists?(login)
      #puts "-- -- #{load_data}"
      load_data.detect { |account_in_db| account_in_db.login == login }
    end

    def user_account(login, password)
      if load_data.map { |account| { login: account.login, password: account.password } }.include?({ login: login, password: password })
        { account: load_data.select { |usr| login == usr.login }.first, error: false }
        #break
      else
        { message: 'There is no account with given credentials', error: true }
        #next
      end
    end

    #def entity_exists?(login)
    #  load_data.map(&:login).include?(login)
    #end
  end
end
