module Spree
  module Admin 
    class ContentResourcesController < Spree::Admin::BaseController
      def new
        @content_resource = ContentResource.create( params[:content_resource] )
      end
      
      def commit
        @content_resource = ContentResource.find( params[:id] )
        #puts "Starting process111111111111111111111111111111111...."
        @lines = @content_resource.parse()
        if !@content_resource.valid
          flash.notice = "Validation failed! Please correct the manifest before click the process button."
          render "validate"
          return
        end
        #puts "Starting process222222222222222222222222222222222...."
       @result = Spree::ContentResource.process(@lines, 0, 3)
      end
      
      
      def update
        @content_resource = ContentResource.find(params[:id])
        @content_resource.uploaded_at = Time.now
        if @content_resource.update_attributes(params[:content_resource])
          flash.notice = flash_message_for(@content_resource, :successfully_updated)
          @lines = @content_resource.parse()
          @failed_line = ""
          @new_line_count = 0
          @update_line_count = 0
          @skip_line_count = 0
          icount = 0
          @lines.each do |line|
            icount += 1
            @failed_line += icount.to_s + "," if !line["valid"].blank?
            if line["action"] == "new"
              @new_line_count += 1
            elsif line["action"] == "update"
              @update_line_count += 1
            else
              @skip_line_count += 1    
             end 
          end
          render "validate"
          #render "uploaded"
        else
          flash.notice = "upload failed! please contact support"
          render "upload_failed"          
        end
      end
      
      
    end
  end
end
