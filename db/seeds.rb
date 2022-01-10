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

Template.create(name: "Print Default",
                template: File.read(Rails.root.join('db', 'fixtures', 'print_default.html.erb')).strip(),
                print_default: true, template_type: "invoice")
Template.create(name: "Print Customer",
                template: File.read(Rails.root.join('db', 'fixtures', 'print_customer.html.erb')).strip(),
                print_default: false, template_type: "customer")

Template.create(name: "Email Default",
                template: File.read(Rails.root.join('db', 'fixtures', 'email_default.html.erb')).strip(),
                subject: "Payment Confirmation: <%= invoice %>",
                email_default: true, template_type: "invoice")
Template.create(name: "Email Customer",
                template: File.read(Rails.root.join('db', 'fixtures', 'email_customer.html.erb')).strip(),
                subject: "Payment Confirmation: <%= customer %>",
                email_default: false, template_type: "customer")
User.create(name: "demo",email: "demo@example.com", password: "secret_password")
Meal.create(name: "BB")
Meal.create(name: "HB")
Meal.create(name: "FB")