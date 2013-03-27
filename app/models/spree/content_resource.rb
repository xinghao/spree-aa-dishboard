require 'csv'
module Spree
  class ContentResource < ActiveRecord::Base
      attr_accessible :avatar
      attr_accessor :valid, :content_lines
      GOLDWATCHCO = "goldwatchco"
            CSV_HEAD = {
"SKU" => "sku",       
"StandardProductID" => "supplier_id",        
"ProductIDType" => "supplier_id_type", 
"ProductName" => "name",   
"TargetAudience1" => "target_audience1",            
"Manufacturer" => "manufacturer",   
"MfrPartNumber" => "mfr_part_number",              
"ItemPrice" => "price",          
"Currency" => "price_currency",             
"Brand" => "brand",   
"ItemType" => "item_type",           
"MainImageURL" => "main_image_url",
"Description" => "description",        
"OtherItemAttribute1" => "other_item_attribute1",    
"OtherItemAttribute2" => "other_item_attribute2",
"OtherImageURL1" => "other_image_url1",            
"OtherImageURL2" => "other_image_url2",
"ProductTaxCode" => "product_tax_code",
"BandWidth" => "band_width",        
"BandWidthUnitOfMeasure" => "band_width_unit_of_measure",
"CaseSizeDiameter" => "case_size_diameter",          
"CaseSizeDiameterUnitOfMeasure" => "case_size_diameter_unit_of_measure",
"DialColor" => "dial_color",
"Crystal" => "crystal",
"ItemShape" => "item_shape",    
"MovementType" => "movement_type",
"WaterResistantDepth" => "water_resistant_depth",   
"DepthUnitOfMeasure" => "depth_unit_of_measure",
"Quantity" => "on_hand"
}

    paperclip_opts = {
      :content_type => { :content_type => "text/csv" },
      :url => '/spree/admin/shipment-manifest/:id/:basename.:extension',
      :path => ':rails_root/public/spree/shipment-manifest/:id/:basename.:extension',
      :s3_headers => lambda { |attachment|
                           { "Content-Type" => "text/csv" }
                           }   
                              
    }
    
    if !Rails.env.development?
      paperclip_opts.merge! :storage        => :s3,
                            :s3_credentials => "#{Rails.root}/config/s3.yml",
#                            :s3_host_name => "s3-ap-southeast-1.amazonaws.com",
                            :path           => 'app/public/spree/shipment-manifest/:id/:basename.:extension'                           
    end

      
    has_attached_file :avatar, paperclip_opts
    
    def self.pull_image(image, url, filename)
        image = Spree::Image.new if image.nil?
        image.attachment = open(url)
        #image.attachment_file_name = filename
        image.save
        return image      
    end
    
    def self.match_taxon(name, gender)
      taxons = Spree::Taxon.where("display = true and taxon_type = ?", "category").order("match_order asc").all
      taxons.each do |taxon|
        match_data = name.match(/#{taxon.match_word}/i)
        return taxon if !match_data.nil? && (taxon.match_gender.blank? || taxon.match_gender.downcase == gender)
      end      
      return nil
    end
    
    
    def self.process(lines, start, limit)
      skip_count = 0
      new_count = 0
      update_count = 0
      icount = 0
      istart = 0
      lines.each do |line|
        
        if icount >= limit && limit > 0
          break
        end
        
        if istart < start
          istart += 1
          next
        end
        
        if line["action"] != "skip"
          
          pattributes = Hash.new
          CSV_HEAD.each_pair do |col_header, key|
            pattributes[key] = line["content"][col_header]["value"]  
          end
          pattributes["permalink"] =  line["content"]["ProductName"]["value"].to_s.to_url
          pattributes["supplier_id"] = GOLDWATCHCO + line["content"]["StandardProductID"]["value"]
#          pattributes["name"] = line["content"]["ProductName"]["value"]
          pattributes["mfr_model"] = ContentResource::retrive_model(line["content"]["MfrPartNumber"]["value"])
#          pattributes["price"] = line["content"]["ItemPrice"]["value"]
          #v = Spree::Variant.find_by_sku(GOLDWATCHCO + line["content"]["SKU"]["value"])
          p = Spree::Product.find_by_supplier_id(pattributes["supplier_id"])
          
          # add images
          new_product = false
          if p.nil?
            new_product = true  
            p = Spree::Product.new
            p.available_on = Time.now
            p.images = Array.new
          end 
                    
          if new_product 
            image = ContentResource::pull_image(nil, line["content"]["MainImageURL"]["value"], line["content"]["StandardProductID"]["value"] + "-1.jpg")
            image.position = 1;
            image.save
            p.images.push image
          elsif p.main_image_url != line["content"]["MainImageURL"]["value"]
            image = ContentResource::pull_image(p.images[0], line["content"]["MainImageURL"]["value"], line["content"]["StandardProductID"]["value"] + "-1.jpg")
            image.save
          end
          
          
          if new_product 
            image = ContentResource::pull_image(nil, line["content"]["OtherImageURL1"]["value"], line["content"]["StandardProductID"]["value"] + "-2.jpg")
            image.position = 2;
            image.save
            p.images.push image            
          elsif p.other_image_url1 != line["content"]["OtherImageURL1"]["value"]
            image = ContentResource::pull_image(p.images[1], line["content"]["OtherImageURL1"]["value"], line["content"]["StandardProductID"]["value"] + "-2.jpg")
            image.save
          end

          if new_product
            image = ContentResource::pull_image(nil, line["content"]["OtherImageURL2"]["value"], line["content"]["StandardProductID"]["value"] + "-3.jpg")
            image.position = 3;
            image.save
            p.images.push image                         
          elsif p.other_image_url2 != line["content"]["OtherImageURL2"]["value"]            
            image = ContentResource::pull_image(p.images[2], line["content"]["OtherImageURL2"]["value"], line["content"]["StandardProductID"]["value"] + "-3.jpg")
            image.save
          end          
          
          # pattributes.each_pair do |key, value|
          #   puts "FFFFFFFFFFFFFFFFFFFFFFFFFFFFF, #{key} -> #{value}"
          # end
          raise "Supplier id #{line["content"]["StandardProductID"]["value"]} failed to update" if !p.update_attributes(pattributes)


          # if category changed
          if line["content"]["ProductName"]["updates"] != "black"
            taxon = ContentResource::match_taxon(line["content"]["ProductName"]["value"], line["content"]["TargetAudience1"]["value"])
            if taxon.nil?
              raise "Unkown category for product #{line["content"]["ProductName"]["value"]}, #{line["content"]["TargetAudience1"]["value"]}"
            end
            
            taxons = p.taxons
            taxons.each do |t|
              p.taxons.delete(t) if t.taxon_type == "category"
            end
            p.taxons = Array.new if taxons.nil?
            p.taxons.push taxon            
          end
           
          
          raise "pull image error or category error" if !p.save
                    
          if new_product
            new_count += 1
            p.set_property("popularity", 0)
          else            
            update_count += 1;
          end
        else
          skip_count += 1;
        end        
        icount += 1;
      end      
      
      return {"skip" => skip_count, "new" => new_count, "update" => update_count}
    end
    
    def parse()
      
      if Rails.env.development?
        url = self.avatar.path
      else
        url = self.avatar.url
      end
      
      icount = 0;
      @valid = true
      @content_lines = Array.new      
      order_count = 0
      integrate_line = nil
      CSV.new(open(url), :headers => :first_row).each do |line|
        cl = Hash.new
        icount += 1;
        
        cl["valid"] = ""
        cl["action"] = "new"
        cl["content"] = Hash.new
        CSV_HEAD.keys.each do |col_header|
          cl["valid"] = "#{col_header} empty or too long" if line[col_header].blank? || (line[col_header].length > 255 && col_header!= "Description" && col_header!= "other_item_attribute1" && col_header!= "other_item_attribute2")          
          cl["content"][col_header] = Hash.new
          cl["content"][col_header]["value"] = line[col_header]
          cl["content"][col_header]["updates"] = "green"
        end
        p = Spree::Product.find_by_supplier_id(GOLDWATCHCO + line["StandardProductID"])

        if !p.nil?
          cl["action"] = "updates" 
          cl["valid"] = "SKU not match for product updates" if p.sku != line["SKU"] 
          change = false
          CSV_HEAD.each_pair do |col_header, key|
              match = true
              if line[col_header] != p.attributes[key]                
                 if (key == "sku" && line[col_header] == p.sku) || (key == "supplier_id" && GOLDWATCHCO + line[col_header] == p.supplier_id) || (key == "price" && line[col_header] + ".0" == p.price.to_s || key == "on_hand" && line[col_header] == p.on_hand.to_s)
                   #puts "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF #{line[col_header]} -> #{p.sku}"                  
                 else                
                    puts "GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG #{line[col_header] + ".00"} == #{p.price.to_s}"               
                    match = false
                 end
             end
                          

             
             if match
               cl["content"][col_header]["updates"] = "black"
             else
               change = true              
               cl["content"][col_header]["updates"] = "red"
             end
          end
          if change
            cl["action"] = "update"
          else
            cl["action"] = "skip"
          end
        end
        
        if ContentResource::retrive_model(line["MfrPartNumber"]).nil?
          cl["valid"] = "can not retrive model from #{line["MfrPartNumber"]}"
        end
        
        if ContentResource::match_taxon(line["ProductName"], line["TargetAudience1"]).nil?
          cl["valid"] = "Unknow category for #{line["ProductName"]} - #{line["TargetAudience1"]}"
        end
        @content_lines.push cl
        @valid = false if !cl["valid"].blank?
     end
     
     return @content_lines

    end  
    
    def self.retrive_model(str)
      a = str.split(".")
      if a.size < 2 || a[0].blank? || a[1].blank?
        return nil
      end
      return a[0]
    end
      
  end
end
