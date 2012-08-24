Spree::AppConfiguration.class_eval do
  preference :cash_on_delivery_charge, :decimal, :default => 4.0
end

