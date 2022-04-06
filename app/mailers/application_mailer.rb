class ApplicationMailer < ActionMailer::Base
  self.smtp_settings = {
    :address              => ENV.fetch("MAILERTOGO_SMTP_HOST"),
    :port                 => ENV.fetch("MAILERTOGO_SMTP_PORT", 587),
    :user_name            => ENV.fetch("MAILERTOGO_SMTP_USER"),
    :password             => ENV.fetch("MAILERTOGO_SMTP_PASSWORD"),
    :domain               => ENV.fetch("MAILERTOGO_DOMAIN", "mydomain.com"),
    :authentication       => :plain,
    :enable_starttls_auto => true
  }
end
