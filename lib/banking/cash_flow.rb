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
      if answer.to_f <= @current_account.card.length && answer.to_f.positive?
        { current_card: @current_account.card[answer.to_i - 1], error: false }
      else
        { message: "You entered wrong number!\n", error: true }
      end
    end

    def correct_amount(amount)
      if amount.to_f.positive?
        { error: false }
      else
        { message: 'You must input correct amount of money', error: true }
      end
    end

    def withdraw_money(current_card, amount, answer)
      money_left = current_card[:balance].to_f - amount.to_f - @tax.withdraw_tax(current_card[:type], amount)

      if money_left.positive?
        current_card[:balance] = money_left
        @current_account.card[answer.to_i - 1] = current_card

        @storage.update_data(@current_account)

        { message: "Money #{amount} withdrawed from #{current_card[:number]}$. Money left: #{current_card[:balance]}$. Tax: #{'%.2f' % @tax.withdraw_tax(current_card[:type], amount)}$",
          return: true }
      else
        { message: "You don't have enough money on card for such operation",
          return: true }
      end
    end

    def put_money(current_card, amount, answer)
      if @tax.put_tax(current_card[:type], amount) >= amount.to_f
        'Your tax is higher than input amount'
      else
        new_money_amount = current_card[:balance].to_f + amount.to_f - @tax.put_tax(current_card[:type], amount)
        current_card[:balance] = new_money_amount
        @current_account.card[answer.to_i - 1] = current_card

        @storage.update_data(@current_account)

        "Money #{amount} was put on #{current_card[:number]}. Balance: #{current_card[:balance]}. Tax: #{'%.2f' % @tax.put_tax(current_card[:type], amount)}"
      end
    end

    def recipient_card_get(card_number)
      if card_number.length > 15 && card_number.length < 17
        all_cards = @storage.load_data.map(&:card).flatten
        if all_cards.select { |card| card[:number] == card_number }.any?
          { recipient_card: all_cards.select { |card| card[:number] == card_number }.first, error: false }
        else
          { message: "There is no card with number #{card_number}\n", error: true }
        end
      else
        { message: 'Please, input correct number of card', error: true }
      end
    end

    def card_balance(amount, sender_card, recipient_card)
      if amount.to_f.positive?
        { sender_modified_balance: sender_card[:balance].to_f - amount.to_f - @tax.sender_tax(sender_card[:type], amount),
          recipient_modified_balance: recipient_card[:balance] + amount.to_f - @tax.put_tax(recipient_card[:type], amount),
          error: false }
      else
        { message: 'You entered wrong number!', error: true }
      end
    end

    def send_money(transaction_data)
      amount = transaction_data[:amount]
      sender_card = transaction_data[:sender_card]
      recipient_card = transaction_data[:recipient_card]

      sender_modified_balance = transaction_data[:sender_modified_balance]
      recipient_modified_balance = transaction_data[:recipient_modified_balance]

      if sender_modified_balance.negative?
        { message: "You don't have enough money on card for such operation", error: true }
      elsif @tax.put_tax(recipient_card[:type], amount) >= amount.to_f
        { message: 'There is no enough money on sender card', error: true }
      else
        sender_card[:balance] = sender_modified_balance
        @current_account.card[transaction_data[:answer].to_i - 1] = sender_card

        @storage.update_data(current_account)

        @storage.update_card_balance(recipient_card[:number], recipient_modified_balance)

        result_info = <<~EOF
          Money #{amount}$ was withdrawn from #{sender_card[:number]}. Balance: #{sender_modified_balance}. Tax: #{'%.2f' % @tax.sender_tax(sender_card[:type], amount)}$
          Money #{amount}$ was put on #{recipient_card[:number]}. Balance: #{recipient_modified_balance}. Tax: #{'%.2f' % @tax.put_tax(recipient_card[:type], amount)}$
        EOF
        { message: result_info, error: false }
      end
    end
  end
end
