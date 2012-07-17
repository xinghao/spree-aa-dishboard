class Spree::Aa::StatsController < Spree::Admin::BaseController
  
  def product_overview
    pp = Spree::Property.find_by_name("popularity");
    @products = Spree::Product.includes(:properties).where("spree_product_properties.property_id = ? and deleted_at is null ", pp.id).order("value desc, spree_products.id desc");
    @stats = Hash.new
    @products.each do |product|
      @stats[product.id] = {"total" => product.master.inventory_units.count, 
                            "shipped" => product.master.inventory_units.where(:state => "shipped").count,
                            "sold" => product.master.inventory_units.where(:state => "sold").count,
                            "backordered" => product.master.inventory_units.where(:state => "backordered").count
                            }  
    end                     
  end
  
end
