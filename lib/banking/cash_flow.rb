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

      return puts(I18n.t(:no_cards)) unless @current_account.card.any?

      @current_account.card.each_with_index do |c, i|
        cards_list_print += "- #{c[:number]}, #{c[:type]}, press #{i + 1}\n"
      end

      cards_list_print += I18n.t(:press_exit)
      @card_any_exists = true

      cards_list_print
    end

    def card_selection(answer)
      if answer.to_f <= @current_account.card.length && answer.to_f.positive?
        { current_card: @current_account.card[answer.to_i - 1], error: false }
      else
        { message: I18n.t(:wrong_number), error: true }
      end
    end

    def correct_amount(amount)
      if amount.to_f.positive?
        { error: false }
      else
        { message: I18n.t(:input_amount), error: true }
      end
    end

    def withdraw_money(current_card, amount)
      money_left = current_card[:balance].to_f - amount.to_f - @tax.withdraw_tax(current_card[:type], amount)

      if money_left.positive?
        @storage.update_card_balance(current_card[:number], money_left)

        { message: I18n.t(:withdrawal_success, amount: amount,
                                               number: current_card[:number],
                                               balance: current_card[:balance],
                                               tax: @tax.withdraw_tax(current_card[:type], amount)),
          return: true }
      else
        { message: I18n.t(:not_enough_money), return: true }
      end
    end

    def put_money(current_card, amount)
      if @tax.put_tax(current_card[:type], amount) >= amount.to_f
        I18n.t(:tax_is_higher)
      else
        new_money_amount = current_card[:balance].to_f + amount.to_f - @tax.put_tax(current_card[:type], amount)

        @storage.update_card_balance(current_card[:number], new_money_amount)

        I18n.t(:putting_success, amount: amount,
                                 number: current_card[:number],
                                 balance: current_card[:balance],
                                 tax: @tax.put_tax(current_card[:type], amount))
      end
    end

    def recipient_card_get(card_number)
      if card_number.length > 15 && card_number.length < 17
        all_cards = @storage.load_data.map(&:card).flatten

        if all_cards.select { |card| card[:number] == card_number }.any?
          { recipient_card: all_cards.select { |card| card[:number] == card_number }.first, error: false }
        else
          { message: I18n.t(:no_such_card, number: card_number), error: true }
        end
      else
        { message: I18n.t(:incorrect_card_number), error: true }
      end
    end

    def card_balance(amount, sender_card, recipient_card)
      if amount.to_f.positive?
        { sender_modified_balance: sender_card[:balance].to_f - amount.to_f -
          @tax.sender_tax(sender_card[:type], amount),
          recipient_modified_balance: recipient_card[:balance] + amount.to_f -
            @tax.put_tax(recipient_card[:type], amount),
          error: false }
      else
        { message: I18n.t(:wrong_number), error: true }
      end
    end

    def send_money(transaction_data)
      amount = transaction_data[:amount]
      sender_card = transaction_data[:sender_card]
      recipient_card = transaction_data[:recipient_card]

      sender_modified_balance = transaction_data[:sender_modified_balance]
      recipient_modified_balance = transaction_data[:recipient_modified_balance]

      if sender_modified_balance.negative?
        { message: I18n.t(:not_enough_money), error: true }
      elsif @tax.put_tax(recipient_card[:type], amount) >= amount.to_f
        { message: I18n.t(:not_enough_money_on_sender), error: true }
      else
        @storage.update_card_balance(sender_card[:number], sender_modified_balance)

        @storage.update_card_balance(recipient_card[:number], recipient_modified_balance)

        result_info = I18n.t(:was_withdrawn, amount: amount,
                                             number: sender_card[:number],
                                             balance: sender_modified_balance,
                                             tax: @tax.sender_tax(sender_card[:type], amount)) +
                      I18n.t(:was_put_on, amount: amount,
                                          number: recipient_card[:number],
                                          balance: recipient_modified_balance,
                                          tax: @tax.put_tax(recipient_card[:type], amount))
        { message:  result_info, error: false }
      end
    end
  end
end
