# frozen_string_literal: true

module Banking
  class Tax
    def withdraw_tax(type, amount)
      return UsualTax.new.withdraw_tax(amount) if type == 'usual'
      return CapitalistTax.new.withdraw_tax(amount) if type == 'capitalist'
      return VirtualTax.new.withdraw_tax(amount) if type == 'virtual'

      0
    end

    def put_tax(type, amount)
      return UsualTax.new.put_tax(amount) if type == 'usual'
      return CapitalistTax.new.put_tax(amount) if type == 'capitalist'
      return VirtualTax.new.put_tax(amount) if type == 'virtual'

      0
    end

    def sender_tax(type, amount)
      return UsualTax.new.sender_tax(amount) if type == 'usual'
      return CapitalistTax.new.sender_tax(amount) if type == 'capitalist'
      return VirtualTax.new.sender_tax(amount) if type == 'virtual'

      0
    end

    def card_tax(card, amount, type_tax)
      return put_tax(card[:type], amount) if type_tax == 'put_tax'
      return withdraw_tax(card[:type], amount) if type_tax == 'withdraw_tax'
      return sender_tax(card[:type], amount) if type_tax == 'sender_tax'
    end
  end
end
