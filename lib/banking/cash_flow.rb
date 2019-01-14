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
      return { message: I18n.t(:input_amount), error: true } unless amount.to_f.positive?

      { error: false }
    end

    def withdraw_money(current_card, amount)
      money_left = change_down_balance(current_card, amount, 'withdraw_tax')

      return { message: I18n.t(:not_enough_money), return: true } unless money_left.positive?

      @storage.update_card_balance(current_card[:number], money_left)

      current_card[:balance] = money_left

      { message: I18n.t(:withdrawal_success, data_for_msg(current_card, amount, 'withdraw_tax')),
        return: true }
    end

    def put_money(current_card, amount)
      if @tax.card_tax(current_card, amount, 'put_tax') >= amount.to_f
        I18n.t(:tax_is_higher)
      else
        new_money_amount = change_up_balance(current_card, amount, 'put_tax')

        @storage.update_card_balance(current_card[:number], new_money_amount)

        current_card[:balance] = new_money_amount

        I18n.t(:putting_success, data_for_msg(current_card, amount, 'put_tax'))
      end
    end

    def recipient_card_get(card_number)
      return { message: I18n.t(:incorrect_card_number), error: true } unless card_number.length == 16

      current_card = @storage.card_by_number(card_number)

      return { message: I18n.t(:no_such_card, number: card_number), error: true } unless current_card

      { recipient_card: current_card, error: false }
    end

    def card_balance(amount, sender_card, recipient_card)
      return { message: I18n.t(:wrong_number), error: true } unless amount.to_f.positive?

      { sender_modified_balance: change_down_balance(sender_card, amount, 'sender_tax'),
        recipient_modified_balance: change_up_balance(recipient_card, amount, 'put_tax'),
        error: false }
    end

    def send_money(data)
      amount = data[:amount]
      recipient_card = data[:recipient_card]

      sender_modified_balance = data[:sender_modified_balance]

      return { message: I18n.t(:not_enough_money), error: true } if sender_modified_balance.negative?

      if @tax.card_tax(recipient_card, amount, 'put_tax') >= amount.to_f
        { message: I18n.t(:not_enough_money_on_sender), error: true }
      else
        sending_money(data)
      end
    end

    private

    def sending_money(data)
      sender_card = data[:sender_card]
      recipient_card = data[:recipient_card]

      @storage.update_card_balance(sender_card[:number], data[:sender_modified_balance])

      @storage.update_card_balance(recipient_card[:number], data[:recipient_modified_balance])

      sender_card[:balance] = data[:sender_modified_balance]
      recipient_card[:balance] = data[:recipient_modified_balance]

      sending_money_msg(sender_card, recipient_card, data[:amount])
    end

    def sending_money_msg(sender_card, recipient_card, amount)
      { message: I18n.t(:was_withdrawn, data_for_msg(sender_card, amount, 'sender_tax')) +
        I18n.t(:was_put_on, data_for_msg(recipient_card, amount, 'put_tax')),
        error: false }
    end

    def change_down_balance(card, amount, type_tax)
      change_balance(:-, card, amount, type_tax)
    end

    def change_up_balance(card, amount, type_tax)
      change_balance(:+, card, amount, type_tax)
    end

    def change_balance(change_type, card, amount, type_tax)
      card[:balance].to_f.send(change_type, amount.to_f - @tax.card_tax(card, amount, type_tax))
    end

    def data_for_msg(card, amount, type_tax)
      { amount: amount, number: card[:number], balance: card[:balance],
        tax: @tax.card_tax(card, amount, type_tax) }
    end
  end
end
