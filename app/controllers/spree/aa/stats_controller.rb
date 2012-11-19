class Spree::Aa::StatsController < Spree::Admin::BaseController
  before_filter :load_date_range, :only => [:sales_overview, :return_overview, :variant_return_overview]
  
  def sales_overview
    @search_url = "/admin/dashboard/stats/sales_overview"; 
    @sales = Array.new
    @sales_products = Hash.new
    @total_products = 0;
    @total_orders = 0
    @total_cost = 0
    @revenue_total = 0;
    @average_revenue = 0;
    @average_net_revenue = 0;
    @payment_total = 0;
    @payment_menthod_hash = Hash.new;
    icount = 0;
    @start_from.to_date.upto(@end_to.to_date) do |day|
      icount += 1;
      day_sale = DailySales.new(day)
      @sales.push day_sale
      @revenue_total += day_sale.total_revenue
      @total_products += day_sale.product_total
      @total_orders += day_sale.orders.size
      @total_cost += day_sale.cost
      @sales_products = DailySales.hash_sum(@sales_products, day_sale.product_hash)
      @payment_total += day_sale.payment_method_total
      @payment_menthod_hash = DailySales.hash_sum_simple(@payment_menthod_hash, day_sale.payment_method_hash);
    end
    
    #@sales_products_array = @sales_products.sort {|a,b| b[1]<=>a[1]}
    @sales_products_array = @sales_products
    
    if icount > 0
      @average_revenue = (@revenue_total * 1.0 /icount).round(2)
      @average_net_revenue = ((@revenue_total - @total_cost) * 1.0 /icount).round(2)
    else
      @average_revenue = @revenue_total
      @average_net_revenue = @revenue_total - @total_cost
    end
    
    
  end
  
  
  def return_overview
    @returns = Spree::InventoryUnit.select("variant_id, count(id) as amount").where("state = ? and updated_at >= ? and updated_at < ?", "returned", @start_from.to_date, @end_to.to_date + 1.day).group("variant_id")    
  end
  
  def variant_return_overview
    @variant_id = params[:id]    
    @returns = Spree::InventoryUnit.select("return_authorization_id, count(id) as amount").where("variant_id = ? and state = ? and updated_at >= ? and updated_at < ?", @variant_id, "returned", @start_from.to_date, @end_to.to_date + 1.day).group("return_authorization_id")    
  end
  
  
  def product_overview
    pp = Spree::Property.find_by_name("popularity");
    @variants = Spree::Variant.includes(:product).where("spree_variants.deleted_at is null and spree_products.deleted_at is null").order("spree_products.name asc")
#    @products = Spree::Product.includes(:properties).where("spree_product_properties.property_id = ? and deleted_at is null ", pp.id).order("value desc, spree_products.id desc");
    @stats = Hash.new
    @variants.each do |variant|
      next if variant.product.has_variants? && variant.is_master 
      @stats[variant.id] = {"variant" => variant,
                            "total" => variant.inventory_units.where("state != ?", "returned").count,
                            "returned" => variant.inventory_units.where(:state => "returned").count, 
                            "shipped" => variant.inventory_units.where(:state => "shipped").count,
                            "sold" => variant.inventory_units.where(:state => "sold").count,
                            "backordered" => variant.inventory_units.where(:state => "backordered").count
                            } 
     if variant.product.has_variants?
       @stats[variant.id]["allow_backorder"] = variant.backorder_limit
       @stats[variant.id]["puchase"] = variant.available?
     else
       @stats[variant.id]["puchase"] = variant.product.purchasable?
       @stats[variant.id]["allow_backorder"] = variant.product.amount_allow_backordered
     end
    end                     
  end
  
end
