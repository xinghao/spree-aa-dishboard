class DailySales
  attr_accessor :date, :orders, :total_revenue, :cost, :total_paid, :item_total_revenue, :product_total, :product_hash, :payment_method_hash, :payment_method_total 
  
  def initialize(date)
    @date = date
    @orders = Spree::Order.includes({:inventory_units => :variant}, :payments).where("state = 'complete' and completed_at >= ? and completed_at < ?", @date, @date + 1.day)
    @total_revenue = 0;
    @total_paid = 0;
    @cost = 0;
    @item_total_revenue = 0;
    @product_total = 0;
    @product_hash = Hash.new;
    @payment_method_hash = {"Paypal Express" => 0, "Eway" => 0, "Other" => 0, "Paypal Express Revenue" => 0, "Eway Revenue" => 0, "Other Revenue" => 0};
    @payment_method_total = 0;
    
    build_report(@orders)    
  end

  def build_report(orders)
    orders.find_each(:batch_size => 100) do |order|
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
      
      ship_fee_per_dollar = (order.total - order.item_total) * 1.0 / order.item_total
      
      order.inventory_units.each do |iu|
        if iu.state != "returned"
          @product_total += 1;
          @cost += iu.variant.product.got_total_cost
          if order.inventory_units.size > 1
            ship_cost = iu.variant.price * ship_fee_per_dollar;
          else
            ship_cost = order.total - order.item_total
          end 
          if @product_hash.has_key?(iu.variant_id)
            @product_hash[iu.variant_id][:quantity] += 1;
            @product_hash[iu.variant_id][:revenue] += ship_cost + iu.variant.price;
          else
            @product_hash[iu.variant_id] = {:quantity => 1, :revenue => ship_cost + iu.variant.price};
          end
        end
      end
      
      
    end
  end

  def increase_payment_method(payment)
    if payment.source_type == "Spree::Creditcard"
      @payment_method_hash["Eway"] += 1 
      @payment_method_hash["Eway Revenue"] += payment.amount
    elsif payment.source_type == "Spree::PaypalAccount"
      @payment_method_hash["Paypal Express"] += 1
      @payment_method_hash["Paypal Express Revenue"] += payment.amount
    else
      @payment_method_hash["Other"] += 1
      @payment_method_hash["Other Revenue"] += payment.amount
    end
  end
  
  def self.hash_sum_simple(hash_a, hash_b)
    hash_b.each_pair do |key, value|
     
      if hash_a.has_key?(key)
        hash_a[key] += value
      else
        hash_a[key] = value 
      end
    end
    return hash_a;
  end

  def self.hash_sum(hash_a, hash_b)
    hash_b.each_pair do |key, value|
      Rails.logger.info("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF" + key.to_s)
      if hash_a.has_key?(key)
        hash_a[key][:quantity] += value[:quantity]
        hash_a[key][:revenue] += value[:revenue]
      else
        hash_a[key] = value 
      end
    end
    return hash_a;
  end


end