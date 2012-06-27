Spree::Core::Engine.routes.draw do
  # Add your extension routes here
  match  'admin/dashboard' => 'Dishboard#index'
  match 'admin/dashboard/shipments/preview' => 'Shipments#preview'
  match 'admin/dashboard/shipments/export_to_csv' => 'Shipments#export_to_csv'  
end

