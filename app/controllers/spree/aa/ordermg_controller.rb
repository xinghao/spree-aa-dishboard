require 'csv'

class Spree::Aa::OrdermgController < Spree::Admin::BaseController
  
  def canceled
    @orders = Spree::Order.includes(:payments).where("state = 'canceled'").order("completed_at asc").all
    @extra_info = Hash.new
    @orders.each do |order|
      @extra_info[order.id] = Hash.new
      @extra_info[order.id]["amount"] = 0
      @extra_info[order.id]["method"] = ""
      order.payments.each do |payment|
        @extra_info[order.id]["amount"] += payment.amount
        @extra_info[order.id]["method"] = payment.payment_method.name if !payment.payment_method.blank? 
      end 
    end
  end
  
  
  def export_to_csv
    filename = "orders-"+Time.now.strftime("%Y%m%d%H%M%S")+".csv"
    # headers.merge!({
    #   'Cache-Control'             => 'must-revalidate, post-check=0, pre-check=0',
    #   'Content-Type'              => 'text/csv',
    #   'Content-Disposition'       => "attachment; filename=\"#{filename}\"",
    #   'Content-Transfer-Encoding' => 'binary'
    # })
    # respond_to :csv  
    
    csv_string = CSV.generate do |csv|
      csv << ['Date', 'Order number', 'Payment state', 'Product', 'Shipping charge', 'Product total', 'GST on product', 'Total']
      Spree::Order.includes(:inventory_units, :shipments).where("state = 'complete' and (payment_state = 'paid' or payment_state = 'balance_due')").order("completed_at asc").find_each(:batch_size => 1000) do |order|
        if (!order.is_test_email?)
          
          rtHash = order.shipments.first.group_all_inventory_units
          
          products = ""        
          rtHash.each_pair do |key, unit| 
            if products.size == 0
              products =  unit["name"] + "(" + unit["quantity"].to_s + ")"
            else
              products += ", " + unit["name"] + "(" + unit["quantity"].to_s + ")"
            end
          end
          
          csv << [order.completed_at, order.number, order.payment_state, products, order.adjustment_total, order.item_total, order.item_total * 0.1, order.total]
        end
      end
    end
    
    send_data csv_string, 
          :type => 'text/csv; charset=iso-8859-1; header=present', 
          :disposition => "attachment; filename=#{filename}" 
  end
  
  
end


