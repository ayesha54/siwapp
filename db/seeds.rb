# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Settings.company_name = ""
Settings.company_address = ""
Settings.company_vat_id = ""
Settings.company_phone = ""
Settings.email_subject = ""
Settings.email_body = ""
Settings.company_email = ""
Settings.company_url = ""
Settings.company_logo = ""
Settings.legal_terms = ""
Settings.currency = "usd"

t = Template.where(name: "Print Default", template_type: "invoice").first
if t
    t.update(template: File.read(Rails.root.join('db', 'fixtures', 'print_default.html.erb')).strip())
else
    Template.create(name: "Print Default",
                    template: File.read(Rails.root.join('db', 'fixtures', 'print_default.html.erb')).strip(),
                    print_default: true, template_type: "invoice")
end

t = Template.where(name: "Print Customer", template_type: "customer").first
if t
    t.update(template: File.read(Rails.root.join('db', 'fixtures', 'print_customer.html.erb')).strip())
else
    Template.create(name: "Print Customer",
                template: File.read(Rails.root.join('db', 'fixtures', 'print_customer.html.erb')).strip(),
                print_default: false, template_type: "customer")
end

t = Template.where(name: "Email Default", template_type: "invoice").first
if t
    t.update(template: File.read(Rails.root.join('db', 'fixtures', 'email_default.html.erb')).strip())
else
    Template.create(name: "Email Default",
                template: File.read(Rails.root.join('db', 'fixtures', 'email_default.html.erb')).strip(),
                subject: "Payment Confirmation: <%= invoice %>",
                email_default: true, template_type: "invoice")
end

t = Template.where(name: "Email Customer", template_type: "customer").first
if t
    t.update(template: File.read(Rails.root.join('db', 'fixtures', 'email_customer.html.erb')).strip())
else
    Template.create(name: "Email Customer",
                template: File.read(Rails.root.join('db', 'fixtures', 'email_customer.html.erb')).strip(),
                subject: "Payment Confirmation: <%= customer %>",
                email_default: false, template_type: "customer")
end
Meal.create(name: 'BB') if Meal.where(name: 'BB').first == nil
Meal.create(name: 'HB') if Meal.where(name: 'HB').first == nil
Meal.create(name: 'FB') if Meal.where(name: 'FB').first == nil
User.create(name: "demo",email: "demo@example.com", password: "secret_password")