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
      if answer.to_i <= @current_account.card.length && answer.to_i.positive?
        { current_card: @current_account.card[answer.to_i - 1], error: false }
      else
        { message: "You entered wrong number!\n", error: true }
      end
    end

    def correct_amount(a2)
      if a2.to_i.positive?
        { error: false}
      else
        { message: 'You must input correct amount of money', error: true }
      end
    end

    def withdraw_money(current_card, a2, answer)
        money_left = current_card[:balance] - a2.to_i - @tax.withdraw_tax(current_card[:type], current_card[:balance], current_card[:number], a2.to_i)
        if money_left.positive?
          current_card[:balance] = money_left
          @current_account.card[answer.to_i - 1] = current_card

          @storage.update_data(@current_account)

          { message: "Money #{a2.to_i} withdrawed from #{current_card[:number]}$. Money left: #{current_card[:balance]}$. Tax: #{@tax.withdraw_tax(current_card[:type], current_card[:balance], current_card[:number], a2.to_i)}$",
            return: true }
        else
          { message: "You don't have enough money on card for such operation",
            return: true }
        end
    end
#---------------------

    def put_money(current_card, a2, answer)
      if @tax.put_tax(current_card[:type], current_card[:balance], current_card[:number], a2.to_i) >= a2.to_i
        'Your tax is higher than input amount'
      else
        new_money_amount = current_card[:balance] + a2.to_i - @tax.put_tax(current_card[:type], current_card[:balance], current_card[:number], a2.to_i)
        current_card[:balance] = new_money_amount
        @current_account.card[answer.to_i - 1] = current_card

        @storage.update_data(@current_account)

        "Money #{a2.to_i} was put on #{current_card[:number]}. Balance: #{current_card[:balance]}. Tax: #{@tax.put_tax(current_card[:type], current_card[:balance], current_card[:number], a2.to_i)}"
      end
    end

#----------------

    def recipient_card_get(a2)
      if a2.length > 15 && a2.length < 17
        all_cards = @storage.load_data.map(&:card).flatten
        if all_cards.select { |card| card[:number] == a2 }.any?
          { recipient_card: all_cards.select { |card| card[:number] == a2 }.first, error: false }
        else
          { message: "There is no card with number #{a2}\n", error: true }
        end
      else
        { message: 'Please, input correct number of card', error: true }
      end
    end

    def card_balance(a3, sender_card, recipient_card)
      if a3.to_i.positive?
        { sender_balance: sender_card[:balance] - a3.to_i - @tax.sender_tax(sender_card[:type], sender_card[:balance], sender_card[:number], a3.to_i),
          recipient_balance: recipient_card[:balance] + a3.to_i - @tax.put_tax(recipient_card[:type], recipient_card[:balance], recipient_card[:number], a3.to_i),
          error: false }
      else
        { message: 'You entered wrong number!\n', error: true }
      end
    end

    def send_money(a3, a2, answer, sender_card, recipient_card, sender_balance, recipient_balance)
      if sender_balance.negative?
        { message: "You don't have enough money on card for such operation", error: true }
      elsif @tax.put_tax(recipient_card[:type], recipient_card[:balance], recipient_card[:number], a3.to_i) >= a3.to_i
        { message: 'There is no enough money on sender card', error: true }
      else
        sender_card[:balance] = sender_balance
        @current_account.card[answer.to_i - 1] = sender_card

        @storage.update_data(current_account)

        @storage.update_card_balance(a2, recipient_balance)

        result_info = <<~EOF
        Money #{a3.to_i}$ was withdrawn from #{sender_card[:number]}. Balance: #{sender_balance}. Tax: #{@tax.sender_tax(sender_card[:type], sender_card[:balance], sender_card[:number], a3.to_i)}$
        Money #{a3.to_i}$ was put on #{a2}. Balance: #{recipient_balance}. Tax: #{@tax.put_tax(sender_card[:type], sender_card[:balance], sender_card[:number], a3.to_i)}$
        EOF
        { message: result_info, error: false }
      end
    end
end
end
