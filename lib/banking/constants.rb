# frozen_string_literal: true

module Constants
  COMMAND_MENU = {
    'SC' => :show_cards,
    'CC' => :create_card,
    'DC' => :destroy_card,
    'PM' => :put_money,
    'WM' => :withdraw_money,
    'SM' => :send_money,
    'DA' => :destroy_account
  }.freeze

  CARD_NUMBER_LENGTH = 16
  NUMBERS_FOR_CARD = 10
end
