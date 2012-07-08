Deface::Override.new(:virtual_path => "spree/layouts/admin",
                     :name => "dashboard_admin_tabs",
                     :insert_bottom => "[data-hook='admin_tabs'], #admin_tabs[data-hook]",
                     :text => "<%= tab(:dashboard, :shipmentmg, :ordermg, :url => '/admin/dashboard') %>",
                     :disabled => false)