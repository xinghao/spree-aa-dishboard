Spree::Core::Engine.routes.draw do
  # Add your extension routes here
  match  'admin/dashboard' => 'Aa::Dashboard#index' 
  match 'admin/dashboard/shipmentmg/preview' => 'Aa::Shipmentmg#preview'
  match 'admin/dashboard/shipmentmg/export_to_csv' => 'Aa::Shipmentmg#export_to_csv'
  match 'admin/dashboard/shipmentmg/upload_overview' => 'Aa::Shipmentmg#upload_overview'
  match 'admin/dashboard/shipmentmg/unshipped_orders' => 'Aa::Shipmentmg#unshipped_orders'
  match 'admin/dashboard/shipmentmg/shipped_orders' => 'Aa::Shipmentmg#shipped_orders'
  match 'admin/dashboard/shipmentmg/all_orders' => 'Aa::Shipmentmg#all_orders'
  
  match '/admin/dashboard/ordermg/export_to_csv' => 'Aa::Ordermg#export_to_csv'
  
  match '/admin/dashboard/stats/product_overview' => 'Aa::Stats#product_overview'
    
end


