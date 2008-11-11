class Notifier < ActionMailer::Base  
  def contact(name, email, phone, content)
    recipients LIBRARY_CONTACT_EMAIL
    from email
    subject "讀者聯絡 #{name}"
    content_type "text/plain"
    body :content => content, :name => name, :phone => phone
  end
end
