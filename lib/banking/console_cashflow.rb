# frozen_string_literal: true

module Banking
  class ConsoleCashFlow
    def put_money
      choose_card = 'Choose the card for putting:'
      input_money = 'Input the amount of money you want to put on your card'
      transaction_request(choose_card, input_money)
      return if @error

      puts @cashflow.put_money(@selected_card[:current_card],
                               @amount_inputted[:amount_inputted])

      current_account_update(@current_account)
    end

    def withdraw_money
      choose_card = 'Choose the card for withdrawing:'
      input_money = 'Input the amount of money you want to withdraw'
      transaction_request(choose_card, input_money)
      return if @error

      withdrawing_finality = @cashflow.withdraw_money(@selected_card[:current_card],
                                                      @amount_inputted[:amount_inputted])

      current_account_update(@current_account)

      return puts(withdrawing_finality[:message]) if withdrawing_finality[:return]
    end

    def send_money
      cards = cards_send_money
      return if @error

      loop do
        puts 'Input the amount of money you want to withdraw'

        transaction_data = transaction_data_formation(cards)
        return if @error

        transaction = sending_money(transaction_data)

        break unless transaction
      end
    end

    private

    def sending_money(transaction_data)
      transaction = @cashflow.send_money(transaction_data)

      puts transaction[:message]

      current_account_update(@current_account)

      transaction[:error]
    end

    def card_determination
      @error = false
      puts @cashflow.cards_list

      return @error = true unless @cashflow.card_any_exists

      answer = gets.chomp

      @error = true if answer == 'exit'

      card_selection = @cashflow.card_selection(answer)

      return { current_card: card_selection[:current_card], answer: answer } unless card_selection[:error]

      puts(card_selection[:message])
      @error = true
    end

    def transaction_amount
      amount_inputted = gets.chomp

      amount = @cashflow.correct_amount(amount_inputted)

      if amount[:error]
        puts amount[:message]
        @error = true
      end
      { amount_inputted: amount_inputted }
    end

    def transaction_request(choose_card, input_money)
      puts choose_card

      @selected_card = card_determination
      return if @error

      puts input_money

      @amount_inputted = transaction_amount
    end

    def cards_send_money
      puts 'Choose the card for sending:'

      sender_card = card_determination
      return if @error

      puts 'Enter the recipient card:'
      card_number = gets.chomp

      recipient_card = @cashflow.recipient_card_get(card_number)

      @error = true if recipient_card[:error]

      return puts(recipient_card[:message]) if recipient_card[:error]

      { answer: sender_card[:answer], sender_card: sender_card[:current_card],
        recipient_card: recipient_card[:recipient_card] }
    end

    def transaction_data_formation(cards)
      amount = gets.chomp

      card_balance = @cashflow.card_balance(amount, cards[:sender_card], cards[:recipient_card])

      @error = true if card_balance[:error]
      return puts(card_balance[:message]) if card_balance[:error]

      sender_modified_balance = card_balance[:sender_modified_balance]
      recipient_modified_balance = card_balance[:recipient_modified_balance]

      cash = { amount: amount,
               sender_modified_balance: sender_modified_balance,
               recipient_modified_balance: recipient_modified_balance }

      cards.merge(cash)
    end

    def current_account_update(account)
      current_account = @storage.user_account(account.login, account.password)

      return puts(current_account[:message]) if current_account[:error]

      @current_account = current_account[:account]
      @card.current_account = @current_account
      @cashflow.current_account = @current_account
    end
  end
end
