module Spree
  class CashOnDelivery::PaymentMethod < Spree::PaymentMethod
    def payment_profiles_supported?
      true # we want to show the confirm step.
    end

    def authorize(*args)
      ActiveMerchant::Billing::Response.new(true, "", {}, {})
    end

    def capture(payment, source, gateway_options)
      payment.update_attribute(:state, 'pending') if payment.state == 'checkout'
      payment.source.send_goods
      ActiveMerchant::Billing::Response.new(true, "", {}, {})
    end

    def void(*args)
      ActiveMerchant::Billing::Response.new(true, "", {}, {})
    end

    def provider_class
      self.class
    end
  
    def payment_source_class
      Spree::CashOnDelivery::Transaction
    end
  
    def method_type
      'cash_on_delivery'
    end
  end
end

