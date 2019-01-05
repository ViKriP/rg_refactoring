# frozen_string_literal: true

module Banking
  class Tax
    def withdraw_tax(type, _balance, _number, amount)
      return amount * 0.05  if type == 'usual'
      return amount * 0.04  if type == 'capitalist'
      return amount * 0.88 if type == 'virtual'
  
      0
    end
  
    def put_tax(type, _balance, _number, amount)
      return amount * 0.02 if type == 'usual'
      return 10 if type == 'capitalist'
      return 1 if type == 'virtual'
  
      0
    end
  
    def sender_tax(type, _balance, _number, amount)
      return 20 if type == 'usual'
      return amount * 0.1  if type == 'capitalist'
      return 1 if type == 'virtual'
  
      0
    end  
  end
end
