# frozen_string_literal: true

module Console
  def console
    HELLO_MSG.each { |msg| puts msg }

    case gets.chomp
    when 'create' then create
    when 'load' then load
    else
      exit
    end
  end

  def main_menu
    loop do
      puts "\nWelcome, #{@current_account.name}"
      MAIN_OPERATIONS_MSG.each { |msg| puts msg }

      case gets.chomp
      when 'SC' then show_cards
      when 'CC' then create_card
      when 'DC' then destroy_card
      when 'PM' then put_money
      when 'WM' then withdraw_money
      when 'SM' then send_money
      when 'DA' then destroy_account
                     exit
      when 'exit' then exit
      else
        puts "Wrong command. Try again!\n"
      end
    end
  end
end
