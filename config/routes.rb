Spree::Core::Engine.routes.draw do
  # Add your extension routes here
  match  'admin/dashboard' => 'Aa::Dishboard#index'
  match 'admin/dashboard/shipments/preview' => 'Aa::Shipments#preview'
  match 'admin/dashboard/shipments/export_to_csv' => 'Aa::Shipments#export_to_csv'  
end

