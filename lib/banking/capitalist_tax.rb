# frozen_string_literal: true

module Banking
  class CapitalistTax < BaseTax
    def withdraw_fixed
      4
    end

    def put_fixed
      10
    end

    def sender_percent
      10
    end
  end
end
