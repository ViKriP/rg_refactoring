# frozen_string_literal: true

CREATE_CARD_MSG = [
  'You could create one of 3 card types',
  '- Usual card. 2% tax on card INCOME. 20$ tax on SENDING money from this card. 5% tax on WITHDRAWING money. For creation this card - press `usual`',
  '- Capitalist card. 10$ tax on card INCOME. 10% tax on SENDING money from this card. 4$ tax on WITHDRAWING money. For creation this card - press `capitalist`',
  '- Virtual card. 1$ tax on card INCOME. 1$ tax on SENDING money from this card. 12% tax on WITHDRAWING money. For creation this card - press `virtual`',
  '- For exit - press `exit`'
].freeze

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