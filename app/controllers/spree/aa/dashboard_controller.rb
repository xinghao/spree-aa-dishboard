module Spree
  module Aa
    
    class DashboardController < Spree::Admin::BaseController
      def index
         
        @orders = Spree::Order.where("(state = 'complete' and payment_state != 'paid') or (state != 'complete' and state != 'cart' and state != 'address'  and  state != 'payment' and state != 'delivery' and state != 'confirm' and state != 'canceled' and state != 'returned' and state != 'awaiting_return' and state != 'resumed')").order("completed_at asc").all 
        
        pp = Spree::Property.find_by_name("popularity");
        @products = Spree::Product.includes(:properties).where("spree_product_properties.property_id = ? and deleted_at is null ", pp.id).order("value desc, spree_products.id desc");                 

      end
    end
  end
end
