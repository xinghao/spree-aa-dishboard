Spree::Core::Engine.routes.draw do
  # Add your extension routes here
  match  'admin/dashboard' => 'Aa::Dashboard#index' 
  match 'admin/dashboard/shipmentmg/preview' => 'Aa::Shipmentmg#preview'
  match 'admin/dashboard/shipmentmg/export_to_csv' => 'Aa::Shipmentmg#export_to_csv'  
end

