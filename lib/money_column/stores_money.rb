module MoneyColumn
  module StoresMoney
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def stores_money(money_name, options = {})
        options.reverse_merge!({
          :cents_column => "#{money_name}_in_cents",
          :allow_nil => true
        })

        class_eval <<-EOV
          def #{money_name}
            cents = send('#{options[:cents_column]}')

            if !#{options[:allow_nil]}
              cents ||= 0
            end
            
            if cents.blank?
              nil
            else
              my_currency = self.respond_to?(:currency) ? currency : ::Money.default_currency
              Money.new(cents, my_currency)
            end
          end
          
          def #{money_name}=(amount)
            self.#{options[:cents_column]} = if amount.blank?
              nil
            else
              amount.to_money.cents
            end
          end
        EOV
      end
    end
  end
end