module Spree
  module Aa
    
    class DashboardController < Spree::Admin::BaseController
      def index
         
        pp = Spree::Property.find_by_name("popularity");
        @products = Spree::Product.includes(:properties).where("spree_product_properties.property_id = ? and deleted_at is null ", pp.id).order("value desc, spree_products.id desc");                 

      end
    end
  end
end
