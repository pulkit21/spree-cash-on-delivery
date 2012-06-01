require File.expand_path(File.join(File.dirname(__FILE__), '..', 'cash_on_delivery.rb'))

module Spree
  module CashOnDelivery
    class Transaction < ActiveRecord::Base
      has_many :payments, :as => :source

      state_machine :initial => 'initial' do
        event :send_goods do
          transition 'initial' => 'goods_sent'
        end

        event :receive_cash do
          transition 'goods_sent' => 'cash_received'
        end
  
        event :void_txn do
          transition 'goods_sent' => 'canceled'
        end
      end

      def post_create(payment)
        payment.order.adjustments.each { |a| a.destroy if a.originator == payment }
        payment.order.adjustments.create(:amount => Spree::Config[:cash_on_delivery_charge],
                                 :source => payment,
                                 :originator => payment,
                                 :label => I18n.t(:shipping_and_handling))
      end

      def update_adjustment(adjustment, src)
        adjustment.update_attribute_without_callbacks(:amount, Spree::Config[:cash_on_delivery_charge])
      end

      def actions
        %w{capture void}
      end
   
      def can_capture?(payment)
        ['checkout', 'pending'].include?(payment.state)
      end
    
      def can_void?(payment)
        payment.state != 'void' and ['goods_sent', 'initial'].include?(payment.source.state)
      end

    end
  end
end