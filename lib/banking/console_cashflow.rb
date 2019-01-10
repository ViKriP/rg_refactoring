# frozen_string_literal: true

module Banking
  class ConsoleCashFlow
    def card_determination
        @error = false
        puts @cashflow.cards_list
        unless @cashflow.card_any_exists
          @error = true
          return
        end
  
        answer = gets.chomp
  
        @error = true if answer == 'exit'
  
        card_selection = @cashflow.card_selection(answer)
  
        #{ current_card: card_selection[:current_card], answer: answer } unless card_selection[:error]
        #puts card_selection[:message]
        #@error = true
  
        if card_selection[:error]
          puts card_selection[:message]
          @error = true
        else
         { current_card: card_selection[:current_card], answer: answer }
        end
      end
  
      def transaction_amount
        a2 = gets.chomp
  
        amount = @cashflow.correct_amount(a2)
  
        if amount[:error]
          puts amount[:message]
          @error = true
        end
        { a2: a2 }
      end
  
      def put_money
        puts 'Choose the card for putting:'
        
        card = card_determination
        return if @error
  
        puts 'Input the amount of money you want to put on your card'
  
        amount = transaction_amount
        return if @error
  
        puts @cashflow.put_money(card[:current_card], amount[:a2], card[:answer])
        return
      end
  
      def withdraw_money
        puts "Choose the card for withdrawing:\n"
        
        card = card_determination
        return if @error
  
        puts 'Input the amount of money you want to withdraw'
  
        amount = transaction_amount
        return if @error
  
        withdrawing_finality = @cashflow.withdraw_money(card[:current_card], amount[:a2], card[:answer])
  
        #return puts withdrawing_finality[:message] if withdrawing_finality[:return]
        if withdrawing_finality[:return]
          puts withdrawing_finality[:message]
          return
        end
      end
  
      def send_money
        puts 'Choose the card for sending:'
  
        sender_card = card_determination
        return if @error
  
        puts 'Enter the recipient card:'
        a2 = gets.chomp
  
        recipient_card = @cashflow.recipient_card_get(a2)
        if recipient_card[:error]
          puts recipient_card[:message]
          return
        end
  
        recipient_card = recipient_card[:recipient_card]
  
        loop do
          puts 'Input the amount of money you want to withdraw'
          a3 = gets.chomp
  
          card_balance = @cashflow.card_balance(a3, sender_card[:current_card], recipient_card)
          if card_balance[:error]
            puts card_balance[:message]
            return
          end
          sender_balance = card_balance[:sender_balance]
          recipient_balance = card_balance[:recipient_balance]
  
          dd = @cashflow.send_money(a3, a2, sender_card[:answer], sender_card[:current_card], recipient_card, sender_balance, recipient_balance)
          puts dd[:message]
          break unless dd[:error]
        end
      end
  end
end  