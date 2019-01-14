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
      money_left = change_down_balance(current_card, amount, 'withdraw_tax')

      if money_left.positive?
        @storage.update_card_balance(current_card[:number], money_left)

        current_card[:balance] = money_left

        { message: I18n.t(:withdrawal_success, data_for_msg(current_card, amount, 'withdraw_tax')),
          return: true }
      else
        { message: I18n.t(:not_enough_money), return: true }
      end
    end

    def put_money(current_card, amount)
      if tax_('put_tax', current_card, amount) >= amount.to_f
        I18n.t(:tax_is_higher)
      else
        new_money_amount = change_up_balance(current_card, amount, 'put_tax')

        @storage.update_card_balance(current_card[:number], new_money_amount)

        current_card[:balance] = new_money_amount

        I18n.t(:putting_success, data_for_msg(current_card, amount, 'put_tax'))
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
        { sender_modified_balance: change_down_balance(sender_card, amount, 'sender_tax'),
          recipient_modified_balance: change_up_balance(recipient_card, amount, 'put_tax'),
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
      elsif tax_('put_tax', recipient_card, amount) >= amount.to_f
        { message: I18n.t(:not_enough_money_on_sender), error: true }
      else
        @storage.update_card_balance(sender_card[:number], sender_modified_balance)

        @storage.update_card_balance(recipient_card[:number], recipient_modified_balance)

        sender_card[:balance] = sender_modified_balance
        recipient_card[:balance] = recipient_modified_balance

        { message: I18n.t(:was_withdrawn, data_for_msg(sender_card, amount, 'sender_tax')) +
          I18n.t(:was_put_on, data_for_msg(recipient_card, amount, 'put_tax')),
          error: false }
      end
    end

    private

    def change_down_balance(card, amount, type_tax)
      change_balance(:-, card, amount, type_tax)
    end

    def change_up_balance(card, amount, type_tax)
      change_balance(:+, card, amount, type_tax)
    end

    def change_balance(change_type, card, amount, type_tax)
      card[:balance].to_f.send(change_type, amount.to_f - tax_(type_tax, card, amount))
    end

    def tax_(type_tax, card, amount)
      return @tax.put_tax(card[:type], amount) if type_tax == 'put_tax'
      return @tax.withdraw_tax(card[:type], amount) if type_tax == 'withdraw_tax'
      return @tax.sender_tax(card[:type], amount) if type_tax == 'sender_tax'
    end

    def msg_transaction_(msg_tag, card, amount, type_tax)
      I18n.t(msg_tag, amount: amount,
                      number: card[:number],
                      balance: card[:balance],
                      tax: tax_(type_tax, card, amount))
    end

    def data_for_msg(card, amount, type_tax)
      { amount: amount, number: card[:number], balance: card[:balance],
        tax: tax_(type_tax, card, amount) }
    end
  end
end
