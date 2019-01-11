# frozen_string_literal: true

module Constants
  # rubocop:disable Metrics/LineLength

  CREATE_CARD_MSG = [
    "You could create one of 3 card types\n\n",
    "- Usual card. \n2% tax on card INCOME. \n20$ tax on SENDING money from this card. \n5% tax on WITHDRAWING money. \nFor creation this card - press `usual`\n\n",
    "- Capitalist card. \n10$ tax on card INCOME. \n10% tax on SENDING money from this card. \n4$ tax on WITHDRAWING money. \nFor creation this card - press `capitalist`\n\n",
    "- Virtual card. \n1$ tax on card INCOME. \n1$ tax on SENDING money from this card. \n12% tax on WITHDRAWING money. \nFor creation this card - press `virtual`\n\n",
    "- For exit - press `exit`\n"
  ].freeze

  # rubocop:enable Metrics/LineLength

  HELLO_MSG = [
    'Hello, we are RubyG bank!',
    '- If you want to create account - press `create`',
    '- If you want to load account - press `load`',
    '- If you want to exit - press `exit`'
  ].freeze

  MAIN_OPERATIONS_MSG = [
    'If you want to:',
    '- show all cards - press SC',
    '- create card - press CC',
    '- destroy card - press DC',
    '- put money on card - press PM',
    '- withdraw money on card - press WM',
    '- send money to another card  - press SM',
    '- destroy account - press `DA`',
    '- exit from account - press `exit`'
  ].freeze

  CARD_NUMBER_LENGTH = 16
  NUMBERS_FOR_CARD = 10
end
