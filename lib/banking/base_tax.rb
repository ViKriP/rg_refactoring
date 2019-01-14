# frozen_string_literal: true

module Banking
  class BaseTax
    def withdraw_tax(amount)
      tax(amount, withdraw_percent, withdraw_fixed)
    end

    def put_tax(amount)
      tax(amount, put_percent, put_fixed)
    end

    def sender_tax(amount)
      tax(amount, sender_percent, sender_fixed)
    end

    private

    def withdraw_percent
      0
    end

    def put_percent
      0
    end

    def sender_percent
      0
    end

    def withdraw_fixed
      0
    end

    def put_fixed
      0
    end

    def sender_fixed
      0
    end

    def tax(amount, percent, fixed)
      amount.to_f * percent.to_f / 100.0 + fixed.to_f
    end
  end
end
