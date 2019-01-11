# frozen_string_literal: true

module Banking
  class VirtualTax < BaseTax
    def withdraw_percent
      12
    end

    def put_fixed
      1
    end

    def sender_fixed
      1
    end
  end
end
