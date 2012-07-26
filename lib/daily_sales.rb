class DailySales
  attr_accessor :date, :orders, :total_revenue, :total_paid, :item_total_revenue, :product_total, :product_hash 
  
  def initialize(date)
    @date = date
    @orders = Spree::Order.includes(:inventory_units, :payments).where("state = 'complete' and completed_at >= ? and completed_at < ?", @date, @date + 1.day)
    @total_revenue = 0;
    @total_paid = 0;
    @item_total_revenue = 0;
    @product_total = 0;
    @product_hash = Hash.new;
    
    build_report(@orders)    
  end

  def build_report(orders)
    orders.find_each(:batch_size => 500) do |order|
      @total_revenue += order.total
      @item_total_revenue += order.item_total
      order.payments.each do |payment|
        #Rails.logger.info("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF, #{payment.id}: #{payment.amount.to_s}, #{payment.state}")
        @total_paid += payment.amount if payment.state == "completed"    
      end    
      
      order.inventory_units.each do |iu|
        @product_total += 1;
        if @product_hash.include?(iu.variant_id)
          @product_hash[iu.variant_id] += 1;
        else
          @product_hash[iu.variant_id] = 1;
        end
      end
      
      
    end
  end

  def self.hash_sum(hash_a, hash_b)
    hash_b.each_pair do |key, value|
      if hash_a.include?(key)
        hash_a[key] += value
      else
        hash_a[key] = value 
      end
    end
    return hash_a;
  end

end