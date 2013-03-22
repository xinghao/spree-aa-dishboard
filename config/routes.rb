Spree::Core::Engine.routes.draw do
  namespace :admin do
    resources :content_resources do 
       put 'commit', :on => :member
     end
  end

  # Add your extension routes here
  match  'admin/dashboard' => 'Aa::Dashboard#index' 
  match 'admin/dashboard/shipmentmg/preview' => 'Aa::Shipmentmg#preview'
  match 'admin/dashboard/shipmentmg/export_to_csv' => 'Aa::Shipmentmg#export_to_csv'
  match 'admin/dashboard/shipmentmg/upload_overview' => 'Aa::Shipmentmg#upload_overview'
  match 'admin/dashboard/shipmentmg/unshipped_orders' => 'Aa::Shipmentmg#unshipped_orders'
  match 'admin/dashboard/shipmentmg/shipped_orders' => 'Aa::Shipmentmg#shipped_orders'
  match 'admin/dashboard/shipmentmg/all_orders' => 'Aa::Shipmentmg#all_orders'
  
  match '/admin/dashboard/ordermg/export_to_csv' => 'Aa::Ordermg#export_to_csv'
  match '/admin/dashboard/ordermg/canceled' => 'Aa::Ordermg#canceled'
  
  match '/admin/dashboard/stats/product_overview' => 'Aa::Stats#product_overview'
  match '/admin/dashboard/stats/sales_overview' => 'Aa::Stats#sales_overview'
  match '/admin/dashboard/stats/return_overview' => 'Aa::Stats#return_overview'
  match '/admin/dashboard/stats/variant_return_overview/:id' => 'Aa::Stats#variant_return_overview'
  
  match 'admin/dashboard/shipmentmg/orders_in_warehourse' => 'Aa::Shipmentmg#orders_in_warehouse'  
    
end


