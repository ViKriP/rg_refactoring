# frozen_string_literal: true

module Banking
  class Card
    attr_accessor :storage, :current_account, :card_any_exists, :card_deleted

    def initialize
      @current_account = Account.new#current_account
      @storage = Storage.new
    end

    def show_cards
      cards = []
      if @current_account.card.any?
        #puts @current_account.card
        @current_account.card.each do |c|
          #aa = "- #{c[:number]}, #{c[:type]}"
          cards.push("- #{c[:number]}, #{c[:type]}")
        end
      else
        cards.push("There is no active cards!\n")
      end
      return cards
    end

    def create_card(card_type)
      if %w[usual capitalist virtual].include?(card_type)
        case card_type
        when 'usual' then card = { type: 'usual', number: Array.new(16) { rand(10) }.join, balance: 50.00 }
        when 'capitalist' then card = { type: 'capitalist', number: Array.new(16) { rand(10) }.join, balance: 100.00 }
        when 'virtual' then card = { type: 'virtual', number: Array.new(16) { rand(10) }.join, balance: 150.00 }
        end

        cards = @current_account.card << card  #<< card #TODO more cards
        @current_account.card = cards
        new_accounts = []

        @storage.load_data.each do |ac| #!!!! .accounts
          if ac.login == @current_account.login
            new_accounts.push(@current_account)
          else
            new_accounts.push(ac)
          end
        end
        Storage.new.save_data(new_accounts)
        false
      else
        return "Wrong card type. Try again!\n"
      end
    end

    def destroy_card_list
      @card_any_exists = false
      if @current_account.card.any?
        card_list = "If you want to delete:\n"

        @current_account.card.each_with_index do |c, i|
          card_list += "- #{c[:number]}, #{c[:type]}, press #{i + 1}" + "\n"
        end
        card_list += "press `exit` to exit\n"
        @card_any_exists = true
        return card_list
      else
        return "There is no active cards!\n"
        #break
      end
    end

    def card_for_destroying(answer)
      descrip = {} 
      if answer&.to_i.to_i <= @current_account.card.length && answer&.to_i.to_i.positive?
        descrip = { content: "Are you sure you want to delete #{@current_account.card[answer&.to_i.to_i - 1][:number]}?[y/n]",
                    error: false }
      else
        descrip = { content: "You entered wrong number!\n", error: true }
      end
    end

    def destroy_card(answer, delete_card)
      @card_deleted = false
      if delete_card == 'y'
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
          @card_deleted = true
          #break  !!!!!!!!!!!!!
        else
          return
        end
    end


=begin
    def destroy_card_
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
=end
  end
end
