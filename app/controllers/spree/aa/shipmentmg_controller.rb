class Spree::Aa::ShipmentmgController < Spree::Admin::BaseController
  before_filter :load_data
  
  
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
end
