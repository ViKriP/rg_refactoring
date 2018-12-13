# frozen_string_literal: true

module Card
  def show_cards
    if @current_account.card.any?
      @current_account.card.each do |c|
        puts "- #{c[:number]}, #{c[:type]}"
      end
    else
      puts "There is no active cards!\n"
    end
  end

  def create_card
    loop do
      CREATE_CARD_MSG.each { |msg| puts msg }
      ct = gets.chomp
      if %w(usual capitalist virtual).include?(ct)
        case ct
        when 'usual' then card = { type: 'usual', number: Array.new(16) { rand(10) }.join, balance: 50.00 }
        when 'capitalist' then card = { type: 'capitalist', number: Array.new(16) { rand(10) }.join, balance: 100.00 }
        when 'virtual' then card = { type: 'virtual', number: Array.new(16) { rand(10) }.join, balance: 150.00 }
        end
        cards = @current_account.card << card
        @current_account.card = cards
        new_accounts = []
        accounts.each do |ac|
          ac.login == @current_account.login ? new_accounts.push(@current_account) :
          new_accounts.push(ac)
        end
        save_data(@file_path, new_accounts)
        break
      else
        puts "Wrong card type. Try again!\n"
      end
    end
  end

  def destroy_card
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
            accounts.each do |ac|
              if ac.login == @current_account.login
                new_accounts.push(@current_account)
              else
                new_accounts.push(ac)
              end
            end
            save_data(@file_path, new_accounts)
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
end
