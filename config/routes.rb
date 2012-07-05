Spree::Core::Engine.routes.draw do
  # Add your extension routes here
  match  'admin/dashboard' => 'Aa::Dashboard#index' 
  match 'admin/dashboard/shipmentmg/preview' => 'Aa::Shipmentmg#preview'
  match 'admin/dashboard/shipmentmg/export_to_csv' => 'Aa::Shipmentmg#export_to_csv'
  match 'admin/dashboard/shipmentmg/upload_overview' => 'Aa::Shipmentmg#upload_overview'
  match 'admin/dashboard/shipmentmg/old_orders' => 'Aa::Shipmentmg#old_orders'
    
end


