Spree::Order.class_eval do
  
  TEST_MAIL_LIST = [
    "betterbequick.com.au",
    "bdirect.com.au",
    "airarena.com",
    "airarena.net",
    "example.net",
    "elton.stewart@gmail.com",
    "elton.stewart\\+30@gmail.com",
    "jameswu36@y7mail.com"    
  ]

  def is_test_email?()
    if !self.user.email.blank?
      TEST_MAIL_LIST.each do |target_string|
        puts target_string
        if (self.user.email =~ /#{target_string}/i)
          return true
        end
      end
    end
    return false     
  end

end