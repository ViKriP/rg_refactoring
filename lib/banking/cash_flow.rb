# frozen_string_literal: true

module Banking
  class CashFlow
    attr_accessor :tax, :storage, :current_account, :card_any_exists

    def initialize
      @tax = Tax.new
      @storage = Storage.new
      @current_account = Account.new
    end

    def cards_list
      @card_any_exists = false
      cards_list_print = ''
      #answer, a2, a3 = nil
      if @current_account.card.any?
        @current_account.card.each_with_index do |c, i|
          cards_list_print += "- #{c[:number]}, #{c[:type]}, press #{i + 1}\n"
        end
        cards_list_print += "press `exit` to exit\n"
        @card_any_exists = true
        return cards_list_print
      else
        return "There is no active cards!\n"
      end
    end

    def card_selection(answer)
      #loop do
      #  answer = gets.chomp
      #  break if answer == 'exit'

        if answer&.to_i.to_i <= @current_account.card.length && answer&.to_i.to_i.positive?
          selected_card = { current_card: @current_account.card[answer&.to_i.to_i - 1], error: false }
        else
          selected_card = { message: "You entered wrong number!\n", error: true }
          #return
        end
      #end
    end

    def correct_amount(a2)
      if a2&.to_i.to_i.positive?
        { error: false}
      else
        { message: 'You must input correct amount of money', error: true }
        #return
      end
    end
=begin
    def withdrawal_amount(current_card, a2) #TODO money = a2
      #puts 'Input the amount of money you want to withdraw'
      #a2 = gets.chomp
      if a2&.to_i.to_i.positive?
        amount_info = { money_left: current_card[:balance] - a2&.to_i.to_i - @tax.withdraw_tax(current_card[:type], current_card[:balance], current_card[:number], a2&.to_i.to_i),
                        error: false }
      else
        amount_info = { message: 'You must input correct amount of $', error: true }
        #return
      end
    end
=end
    def withdraw_money(current_card, a2, answer)
      #puts 'Input the amount of money you want to withdraw'
      #a2 = gets.chomp
      #if a2&.to_i.to_i.positive?
        money_left = current_card[:balance] - a2&.to_i.to_i - @tax.withdraw_tax(current_card[:type], current_card[:balance], current_card[:number], a2&.to_i.to_i)
        if money_left.positive?
          current_card[:balance] = money_left
          @current_account.card[answer&.to_i.to_i - 1] = current_card
          new_accounts = []
          @storage.load_data.each do |ac|
            if ac.login == @current_account.login
              new_accounts.push(@current_account)
            else
              new_accounts.push(ac)
            end
          end
          @storage.save_data(new_accounts)
          withdrawing_amount_info = { message: "Money #{a2&.to_i.to_i} withdrawed from #{current_card[:number]}$. Money left: #{current_card[:balance]}$. Tax: #{@tax.withdraw_tax(current_card[:type], current_card[:balance], current_card[:number], a2&.to_i.to_i)}$",
                                      return: true }
  
          #return
        else
          withdrawing_amount_info = { message: "You don't have enough money on card for such operation",
                                      return: true }
          #return
        end
      #else
      #  puts 'You must input correct amount of $'
      #  #return
      #end
    end
#---------------------

    #def wrong_number
    #  if answer&.to_i.to_i <= @current_account.card.length && answer&.to_i.to_i.positive?
    #    current_card = @current_account.card[answer&.to_i.to_i - 1]
    #  else
    #    puts "You entered wrong number!\n"
    #    #return
    #  end
    #end
=begin
    def correct_amount(a2)
      if a2&.to_i.to_i.positive?
        { error: false}
      else
        { message: 'You must input correct amount of money', error: true }
        #return
      end
    end
=end
    def put_money(current_card, a2, answer)
      if @tax.put_tax(current_card[:type], current_card[:balance], current_card[:number], a2&.to_i.to_i) >= a2&.to_i.to_i
        return 'Your tax is higher than input amount'
        #return
      else
        new_money_amount = current_card[:balance] + a2&.to_i.to_i - @tax.put_tax(current_card[:type], current_card[:balance], current_card[:number], a2&.to_i.to_i)
        current_card[:balance] = new_money_amount
        @current_account.card[answer&.to_i.to_i - 1] = current_card
        new_accounts = []
        @storage.load_data.each do |ac|
          if ac.login == @current_account.login
            new_accounts.push(@current_account)
          else
            new_accounts.push(ac)
          end
        end
        @storage.save_data(new_accounts)
        return "Money #{a2&.to_i.to_i} was put on #{current_card[:number]}. Balance: #{current_card[:balance]}. Tax: #{@tax.put_tax(current_card[:type], current_card[:balance], current_card[:number], a2&.to_i.to_i)}"
        #return
      end
    end

=begin
  def put_money
    puts 'Choose the card for putting:'

    if @current_account.card.any?
      @current_account.card.each_with_index do |c, i|
        puts "- #{c[:number]}, #{c[:type]}, press #{i + 1}"
      end
      puts "press `exit` to exit\n"

      loop do
        answer = gets.chomp
        break if answer == 'exit'
        
        if answer&.to_i.to_i <= @current_account.card.length && answer&.to_i.to_i.positive?
          current_card = @current_account.card[answer&.to_i.to_i - 1]

          loop do
            puts 'Input the amount of money you want to put on your card'
            a2 = gets.chomp
            if a2&.to_i.to_i.positive?
              if @tax.put_tax(current_card[:type], current_card[:balance], current_card[:number], a2&.to_i.to_i) >= a2&.to_i.to_i
                puts 'Your tax is higher than input amount'
                return
              else
                new_money_amount = current_card[:balance] + a2&.to_i.to_i - @tax.put_tax(current_card[:type], current_card[:balance], current_card[:number], a2&.to_i.to_i)
                current_card[:balance] = new_money_amount
                @current_account.card[answer&.to_i.to_i - 1] = current_card
                new_accounts = []
                @storage.accounts.each do |ac|
                  if ac.login == @current_account.login
                    new_accounts.push(@current_account)
                  else
                    new_accounts.push(ac)
                  end
                end
                @storage.save_data(new_accounts)
                puts "Money #{a2&.to_i.to_i} was put on #{current_card[:number]}. Balance: #{current_card[:balance]}. Tax: #{put_tax(current_card[:type], current_card[:balance], current_card[:number], a2&.to_i.to_i)}"
                return
              end
            else
              puts 'You must input correct amount of money'
              return
            end
          end
        else
          puts "You entered wrong number!\n"
          return
        end
      end
    else
      puts "There is no active cards!\n"
    end
  end

  def send_money
    puts 'Choose the card for sending:'

    if @current_account.card.any?
      @current_account.card.each_with_index do |c, i|
        puts "- #{c[:number]}, #{c[:type]}, press #{i + 1}"
      end
      puts "press `exit` to exit\n"
      answer = gets.chomp
      exit if answer == 'exit'
      if answer&.to_i.to_i <= @current_account.card.length && answer&.to_i.to_i.positive?
        sender_card = @current_account.card[answer&.to_i.to_i - 1]
      else
        puts 'Choose correct card'
        return
      end
    else
      puts "There is no active cards!\n"
      return
    end

    puts 'Enter the recipient card:'
    a2 = gets.chomp
    if a2.length > 15 && a2.length < 17
      all_cards = @storage.accounts.map(&:card).flatten
      if all_cards.select { |card| card[:number] == a2 }.any?
        recipient_card = all_cards.select { |card| card[:number] == a2 }.first
      else
        puts "There is no card with number #{a2}\n"
        return
      end
    else
      puts 'Please, input correct number of card'
      return
    end

    loop do
      puts 'Input the amount of money you want to withdraw'
      a3 = gets.chomp
      if a3&.to_i.to_i.positive?
        sender_balance = sender_card[:balance] - a3&.to_i.to_i - @tax.sender_tax(sender_card[:type], sender_card[:balance], sender_card[:number], a3&.to_i.to_i)
        recipient_balance = recipient_card[:balance] + a3&.to_i.to_i - @tax.put_tax(recipient_card[:type], recipient_card[:balance], recipient_card[:number], a3&.to_i.to_i)

        if sender_balance.negative?
          puts "You don't have enough money on card for such operation"
        elsif put_tax(recipient_card[:type], recipient_card[:balance], recipient_card[:number], a3&.to_i.to_i) >= a3&.to_i.to_i
          puts 'There is no enough money on sender card'
        else
          sender_card[:balance] = sender_balance
          @current_account.card[answer&.to_i.to_i - 1] = sender_card
          new_accounts = []
          @storage.accounts.each do |ac|
            if ac.login == @current_account.login
              new_accounts.push(@current_account)
            elsif ac.card.map { |card| card[:number] }.include? a2
              recipient = ac
              new_recipient_cards = []
              recipient.card.each do |card|
                card[:balance] = recipient_balance if card[:number] == a2
                new_recipient_cards.push(card)
              end
              recipient.card = new_recipient_cards
              new_accounts.push(recipient)
            end
          end
          @storage.save_data(new_accounts)
          puts "Money #{a3&.to_i.to_i}$ was put on #{sender_card[:number]}. Balance: #{recipient_balance}. Tax: #{@tax.put_tax(sender_card[:type], sender_card[:balance], sender_card[:number], a3&.to_i.to_i)}$\n"
          puts "Money #{a3&.to_i.to_i}$ was put on #{a2}. Balance: #{sender_balance}. Tax: #{@tax.sender_tax(sender_card[:type], sender_card[:balance], sender_card[:number], a3&.to_i.to_i)}$\n"
          break
        end
      else
        puts 'You entered wrong number!\n'
      end
    end
  end

=end

end
end
