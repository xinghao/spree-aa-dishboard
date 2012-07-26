class Spree::Aa::StatsController < Spree::Admin::BaseController
  before_filter :load_date_range, :only => [:sales_overview]
  
  def sales_overview
    @search_url = "/admin/dashboard/stats/sales_overview"; 
    @sales = Array.new
    @sales_products = Hash.new
    @total_products = 0;
    @revenue_total = 0;
    @average_revenue = 0;
    icount = 0;
    @start_from.to_date.upto(@end_to.to_date) do |day|
      icount += 1;
      day_sale = DailySales.new(day)
      @sales.push day_sale
      @revenue_total += day_sale.total_revenue
      @total_products += day_sale.product_total
      @sales_products = DailySales.hash_sum(@sales_products, day_sale.product_hash)
    end
    if icount > 0
      @average_revenue = @revenue_total * 1.0 /icount
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
