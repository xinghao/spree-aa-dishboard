class Spree::Aa::StatsController < Spree::Admin::BaseController
  before_filter :load_date_range, :only => [:sales_overview]
  
  def sales_overview
    @search_url = "/admin/dashboard/stats/sales_overview"; 
    @sales = Array.new
    @sales_products = Hash.new
    @total_products = 0;
    @total_orders = 0
    @revenue_total = 0;
    @average_revenue = 0;
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
      @sales_products = DailySales.hash_sum(@sales_products, day_sale.product_hash)
      @payment_total += day_sale.payment_method_total
      @payment_menthod_hash = DailySales.hash_sum(@payment_menthod_hash, day_sale.payment_method_hash);
    end
    @sales_products_array = @sales_products.sort {|a,b| b[1]<=>a[1]}
    
    if icount > 0
      @average_revenue = (@revenue_total * 1.0 /icount).round(2)
    else
      @average_revenue = @revenue_total
    end
    
    
  end
  
  
  def load_date_range
    @start_from = params[:start]
    @end_to = params[:end]
    
    if !params[:start].blank?
      begin
       @start_from = DateTime.strptime(params[:start], '%Y/%m/%d').to_time
      rescue
       @start_from = nil
      end
    end
    
    if !params[:end].blank?
      begin
       @end_to = DateTime.strptime(params[:end], '%Y/%m/%d').to_time
      rescue
       @end_to = nil
      end
    else
      @end_to = Date.today.strftime('%Y/%m/%d').to_time
    end    
    
    @start_from = @end_to if @start_from.nil?
  end
  
  
  def product_overview
    pp = Spree::Property.find_by_name("popularity");
    @variants = Spree::Variant.includes(:product).where("spree_variants.deleted_at is null and spree_products.deleted_at is null").order("spree_products.name asc")
#    @products = Spree::Product.includes(:properties).where("spree_product_properties.property_id = ? and deleted_at is null ", pp.id).order("value desc, spree_products.id desc");
    @stats = Hash.new
    @variants.each do |variant|
      next if variant.product.has_variants? && variant.is_master 
      @stats[variant.id] = {"variant" => variant,
                            "total" => variant.inventory_units.count, 
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
