Spree::Product.class_eval do
      
  def get_property(key)
    product_properties.each do |product_property|
      return product_property.value if product_property.property_name == key;
    end
    
    return nil;    
  end
  
  def get_fob()
    tmpStr = get_property("fob")
    return 0 if tmpStr.nil? || tmpStr == ""
    begin
      return tmpStr.to_f
    rescue
      return 0
    end    
  end
  
  def got_total_cost()
    tmpStr = get_property("total_cost")
    return 0 if tmpStr.nil? || tmpStr == ""
    begin
      return tmpStr.to_f
    rescue
      return 0
    end    
  end
  
end