class DailySales
  attr_accessor :date, :orders, :total_revenue, :total_paid, :item_total_revenue, :product_total, :product_hash, :payment_method_hash, :payment_method_total 
  
  def initialize(date)
    @date = date
    @orders = Spree::Order.includes(:inventory_units, :payments).where("state = 'complete' and completed_at >= ? and completed_at < ?", @date, @date + 1.day)
    @total_revenue = 0;
    @total_paid = 0;
    @item_total_revenue = 0;
    @product_total = 0;
    @product_hash = Hash.new;
    @payment_method_hash = {"Paypal Express" => 0, "Eway" => 0, "Other" => 0};
    @payment_method_total = 0;
    
    build_report(@orders)    
  end

  def build_report(orders)
    orders.find_each(:batch_size => 500) do |order|
      @total_revenue += order.total
      @item_total_revenue += order.item_total
      order.payments.each do |payment|
        #Rails.logger.info("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF, #{payment.id}: #{payment.amount.to_s}, #{payment.state}")
        if payment.state == "completed"
          @total_paid += payment.amount 
          @payment_method_total += 1
          increase_payment_method(payment)
        end    
      end    
      
      order.inventory_units.each do |iu|
        @product_total += 1;
        if @product_hash.has_key?(iu.variant_id)
          @product_hash[iu.variant_id] += 1;
        else
          @product_hash[iu.variant_id] = 1;
        end
      end
      
      
    end
  end

  def increase_payment_method(payment)
    if payment.source_type == "Spree::Creditcard"
      @payment_method_hash["Eway"] += 1 
    elsif payment.source_type == "Spree::PaypalAccount"
      @payment_method_hash["Paypal Express"] += 1
    else
      @payment_method_hash["Other"] += 1
    end
  end
  
  def self.hash_sum(hash_a, hash_b)
    hash_b.each_pair do |key, value|
      if hash_a.has_key?(key)
        hash_a[key] += value
      else
        hash_a[key] = value 
      end
    end
    return hash_a;
  end

end