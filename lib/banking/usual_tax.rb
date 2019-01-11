# frozen_string_literal: true

module Banking
  class UsualTax < BaseTax
    def withdraw_percent
      5
    end

    def put_percent
      2
    end

    def sender_fixed
      20
    end
  end
end
