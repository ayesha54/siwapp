class ApplicationMailer < ActionMailer::Base
  mailertogo_host     = ENV.fetch("MAILERTOGO_SMTP_HOST")
  mailertogo_port     = ENV.fetch("MAILERTOGO_SMTP_PORT", 587)
  mailertogo_user     = ENV.fetch("MAILERTOGO_SMTP_USER")
  mailertogo_password = ENV.fetch("MAILERTOGO_SMTP_PASSWORD")
  mailertogo_domain   = ENV.fetch("MAILERTOGO_DOMAIN", "mydomain.com")
  self.smtp_settings = {
    :address              => mailertogo_host,
    :port                 => mailertogo_port,
    :user_name            => mailertogo_user,
    :password             => mailertogo_password,
    :domain               => mailertogo_domain,
    :authentication       => :plain,
    :enable_starttls_auto => true
  }
end
