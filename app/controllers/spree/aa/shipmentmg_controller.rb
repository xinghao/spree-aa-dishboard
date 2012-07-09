require 'csv'

class Spree::Aa::ShipmentmgController < Spree::Admin::BaseController
  before_filter :load_data, :only => [:preview, :export_to_csv]
  
  
  #{order_id1=>{"prview_object" => prview_object1, "order"=>order1},order_id2=>{"prview_object" => prview_object2, "order"=>order2}}
  def load_data
    # orders = Spree::Order.includes(:ship_address).where("state = 'complete' and payment_state = 'paid'").order("completed_at asc").all
    # @display_hash = Hash.new
    # orders.each do |order|
    #   if order.shipments.first.shipping_events.present? && !order.shipments.first.all_shipped?
    #     @display_hash[order.id] = {"preview_object" => ShipmentPreviewObject.build_from_order(order), "order" => order}
    #   end 
    # end
    @display_hash = ShipmentPreviewObject.build_display_data   
  end
  
  def preview
    @total_send_products = 0
    @display_hash.each_pair do |order_id,value|
      order = value["order"]
      @total_send_products += order.inventory_units.where("state = ?", "sold").count
    end
  end
  
  def upload_overview
  end
  
  def export_to_csv
    filename = "shipments-"+Time.now.strftime("%Y%m%d%H%M%S")+".csv"
    # headers.merge!({
    #   'Cache-Control'             => 'must-revalidate, post-check=0, pre-check=0',
    #   'Content-Type'              => 'text/csv',
    #   'Content-Disposition'       => "attachment; filename=\"#{filename}\"",
    #   'Content-Transfer-Encoding' => 'binary'
    # })
    # respond_to :csv  
    csv_string = Spree::Order.export_avaible_shipments_to_csv(@display_hash)
    send_data csv_string, 
          :type => 'text/csv; charset=iso-8859-1; header=present', 
          :disposition => "attachment; filename=#{filename}" 
  end
  
  # only work for shipped_orders and all_orders
  def export_orders_to_csv(filename, select)
    csv_string = CSV.generate do |csv|
      csv << ["order number", "date", "payment_state", "shipment_state", "first name", "last name", "email", "address1", "address2", "suburb", "state", "postcode", "phone", "products", "multi products"]
      
      select.order("completed_at asc").find_each(:batch_size => 1000) do |order|
        if (!order.is_test_email?)
          address1 = order.ship_address.address1
          address2 = order.ship_address.address2
          rtHash = order.shipments.first.group_all_inventory_units  ## important
          
          products = ""        
          rtHash.each_pair do |key, unit| 
            if products.size == 0
              products =  unit["name"] + "(" + unit["quantity"].to_s + ")"
            else
              products += ", " + unit["name"] + "(" + unit["quantity"].to_s + ")"
            end
          end
          multi_products = ""
          multi_products = "true" if rtHash.size > 1
          address1 = address1 + " " + address2 if !address2.nil? && address2.size > 0        
          csv << [order.number, order.completed_at, order.payment_state, order.shipment_state, order.ship_address.firstname,order.ship_address.lastname, order.user.email, order.ship_address.address1, order.ship_address.address2, order.ship_address.city, order.ship_address.state_text, order.ship_address.zipcode, order.ship_address.phone, products, multi_products]
        end  
      end
    end 
    
    send_data csv_string, 
          :type => 'text/csv; charset=iso-8859-1; header=present', 
          :disposition => "attachment; filename=#{filename}"            
  end
  
  def all_orders 
    filename = "all-orders.csv"
    select = Spree::Order.includes(:ship_address, :inventory_units, :line_items, :user).where("state = 'complete' and shipment_state = 'shipped'");
    export_orders_to_csv(filename, select)        
  end
  
  # does not include paritial shipped orders
  def shipped_orders
    filename = "shipped-orders.csv"
    select = Spree::Order.includes(:ship_address, :inventory_units, :line_items, :user).where("state = 'complete' and shipment_state = 'shipped'");
    export_orders_to_csv(filename, select)    
  end
  
  def unshipped_orders
    filename = "unshipped-orders.csv"
    
    
    csv_string = CSV.generate do |csv|
      csv << ["order number", "date", "payment_state", "shipment_state", "first name", "last name", "email", "address1", "address2", "suburb", "state", "postcode", "phone", "products", "multi products"]
      
      Spree::Order.includes(:ship_address, :inventory_units, :line_items, :user).where("state = 'complete' and shipment_state != 'shipped'").order("completed_at asc").find_each(:batch_size => 1000) do |order|
        address1 = order.ship_address.address1
        address2 = order.ship_address.address2
        rtHash = order.shipments.first.group_not_shipped_inventory_units   # <--- difference is here
        
        products = ""        
        rtHash.each_pair do |key, unit| 
          if products.size == 0
            products =  unit["name"] + "(" + unit["quantity"].to_s + ")"
          else
            products += ", " + unit["name"] + "(" + unit["quantity"].to_s + ")"
          end
        end
        multi_products = ""
        multi_products = "true" if rtHash.size > 1
        address1 = address1 + " " + address2 if !address2.nil? && address2.size > 0        
        csv << [order.number, order.completed_at, order.payment_state, order.shipment_state, order.ship_address.firstname,order.ship_address.lastname, order.user.email, order.ship_address.address1, order.ship_address.address2, order.ship_address.city, order.ship_address.state_text, order.ship_address.zipcode, order.ship_address.phone, products, multi_products]  
      end
    end 
    
    send_data csv_string, 
          :type => 'text/csv; charset=iso-8859-1; header=present', 
          :disposition => "attachment; filename=#{filename}"        
  end
end
