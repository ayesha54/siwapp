# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2022_01_21_162005) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "beds", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "price"
    t.bigint "room_id"
    t.string "name"
    t.index ["room_id"], name: "index_beds_on_room_id"
  end

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "commons", force: :cascade do |t|
    t.integer "series_id"
    t.string "name", limit: 100
    t.string "identification", limit: 50
    t.string "email", limit: 100
    t.text "invoicing_address"
    t.text "shipping_address"
    t.string "contact_person", limit: 100
    t.text "terms"
    t.text "notes"
    t.decimal "net_amount", precision: 53, scale: 15, default: "0.0"
    t.decimal "gross_amount", precision: 53, scale: 15, default: "0.0"
    t.decimal "paid_amount", precision: 53, scale: 15, default: "0.0"
    t.string "type", limit: 255
    t.boolean "draft", default: false
    t.boolean "paid", default: false
    t.boolean "sent_by_email", default: false
    t.integer "number"
    t.integer "recurring_invoice_id"
    t.date "issue_date"
    t.date "due_date"
    t.integer "days_to_due"
    t.boolean "enabled", default: true
    t.integer "max_occurrences"
    t.integer "must_occurrences"
    t.integer "period"
    t.string "period_type", limit: 8
    t.date "starting_date"
    t.date "finishing_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.integer "print_template_id"
    t.text "meta_attributes"
    t.boolean "failed", default: false
    t.integer "email_template_id"
    t.integer "deleted_number"
    t.string "currency", limit: 3
    t.index ["contact_person"], name: "cntct_idx"
    t.index ["deleted_at"], name: "index_commons_on_deleted_at"
    t.index ["email"], name: "cstml_idx"
    t.index ["identification"], name: "cstid_idx"
    t.index ["name"], name: "cstnm_idx"
    t.index ["recurring_invoice_id"], name: "common_recurring_invoice_id_common_id"
    t.index ["series_id", "deleted_number"], name: "common_deleted_number_idx"
    t.index ["series_id", "number"], name: "common_unique_number_idx", unique: true
    t.index ["series_id"], name: "series_id_idx"
    t.index ["type"], name: "common_type_idx"
    t.index ["type"], name: "type_and_status_idx"
  end

  create_table "customer_item_taxes", force: :cascade do |t|
    t.integer "customer_item_id"
    t.integer "tax_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "customer_items", force: :cascade do |t|
    t.bigint "room_id"
    t.bigint "bed_id"
    t.decimal "quantity"
    t.decimal "discount"
    t.string "description"
    t.float "net_amount"
    t.integer "tax"
    t.decimal "unitary_cost"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "customer_id"
    t.index ["bed_id"], name: "index_customer_items_on_bed_id"
    t.index ["customer_id"], name: "index_customer_items_on_customer_id"
    t.index ["room_id"], name: "index_customer_items_on_room_id"
  end

  create_table "customer_tax", force: :cascade do |t|
    t.integer "customer_id"
    t.integer "tax_id"
  end

  create_table "customer_taxes", force: :cascade do |t|
    t.integer "customer_id"
    t.integer "tax_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "customers", force: :cascade do |t|
    t.string "name", limit: 100
    t.string "name_slug", limit: 100
    t.string "identification", limit: 50
    t.string "email", limit: 100
    t.string "contact_person", limit: 100
    t.text "invoicing_address"
    t.text "shipping_address"
    t.datetime "deleted_at"
    t.text "meta_attributes"
    t.boolean "active", default: true
    t.date "check_in"
    t.date "check_out"
    t.integer "print_template_id"
    t.integer "email_template_id"
    t.string "meal"
    t.index ["deleted_at"], name: "index_customers_on_deleted_at"
    t.index ["name_slug"], name: "cstm_slug_idx", unique: true
  end

  create_table "inventories", force: :cascade do |t|
    t.string "name"
    t.float "price"
    t.bigint "category_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_inventories_on_category_id"
  end

  create_table "items", force: :cascade do |t|
    t.decimal "quantity", precision: 53, scale: 15, default: "1.0", null: false
    t.decimal "discount", precision: 53, scale: 2, default: "0.0", null: false
    t.integer "common_id"
    t.string "description", limit: 20000
    t.decimal "unitary_cost", precision: 53, scale: 15, default: "0.0", null: false
    t.integer "product_id"
    t.datetime "deleted_at"
    t.integer "category_id"
    t.integer "inventory_id"
    t.float "net_amount", default: 0.0
    t.index ["common_id"], name: "common_id_idx"
    t.index ["deleted_at"], name: "index_items_on_deleted_at"
    t.index ["description"], name: "desc_idx"
    t.index ["product_id"], name: "item_product_id_idx"
  end

  create_table "items_services", id: false, force: :cascade do |t|
    t.integer "item_id", null: false
    t.integer "service_id", null: false
  end

  create_table "items_taxes", force: :cascade do |t|
    t.integer "tax_id"
    t.integer "item_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "line_invoices", force: :cascade do |t|
    t.bigint "commons_id"
    t.integer "inventory"
    t.integer "category"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["commons_id"], name: "index_line_invoices_on_commons_id"
  end

  create_table "meals", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "payments", force: :cascade do |t|
    t.integer "invoice_id", null: false
    t.date "date"
    t.decimal "amount", precision: 53, scale: 15
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_payments_on_deleted_at"
    t.index ["invoice_id"], name: "invoice_id_idx"
  end

  create_table "payments_customer", force: :cascade do |t|
    t.integer "customer_id"
    t.date "date"
    t.decimal "amount"
    t.string "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "payments_customers", force: :cascade do |t|
    t.integer "customer_id"
    t.date "date"
    t.decimal "amount"
    t.string "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "products", force: :cascade do |t|
    t.string "reference", limit: 100, null: false
    t.text "description"
    t.decimal "price", precision: 53, scale: 15, default: "0.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_products_on_deleted_at"
  end

  create_table "rooms", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "series", force: :cascade do |t|
    t.string "name", limit: 255
    t.string "value", limit: 255
    t.boolean "enabled", default: true
    t.boolean "default", default: false
    t.datetime "deleted_at"
    t.integer "first_number", default: 1
    t.index ["deleted_at"], name: "index_series_on_deleted_at"
  end

  create_table "services", force: :cascade do |t|
    t.string "name", limit: 50
    t.decimal "value", precision: 53, scale: 2
    t.boolean "active", default: true
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_services_on_deleted_at"
  end

  create_table "settings", force: :cascade do |t|
    t.string "var", limit: 255, null: false
    t.text "value"
    t.integer "thing_id"
    t.string "thing_type", limit: 30
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["thing_type", "thing_id", "var"], name: "index_settings_on_thing_type_and_thing_id_and_var", unique: true
  end

  create_table "taggings", force: :cascade do |t|
    t.integer "tag_id"
    t.string "taggable_type", limit: 255
    t.integer "taggable_id"
    t.integer "tagger_id"
    t.string "tagger_type", limit: 255
    t.string "context", limit: 128
    t.datetime "created_at"
    t.index ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true
    t.index ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context"
  end

  create_table "tags", force: :cascade do |t|
    t.string "name", limit: 255
    t.integer "taggings_count", default: 0
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "taxes", force: :cascade do |t|
    t.string "name", limit: 50
    t.decimal "value", precision: 53, scale: 2
    t.boolean "active", default: true
    t.boolean "default", default: false
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_taxes_on_deleted_at"
  end

  create_table "templates", force: :cascade do |t|
    t.string "name", limit: 255
    t.text "template"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "models", limit: 200
    t.boolean "print_default", default: false
    t.datetime "deleted_at"
    t.boolean "email_default", default: false
    t.string "subject", limit: 200
    t.string "template_type"
    t.index ["deleted_at"], name: "index_templates_on_deleted_at"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", limit: 255
    t.string "email", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest", limit: 255
    t.string "remember_digest", limit: 255
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  create_table "webhook_logs", force: :cascade do |t|
    t.string "level", limit: 255, default: "info", null: false
    t.string "message", limit: 255
    t.string "event", limit: 255, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event"], name: "index_webhook_logs_on_event"
  end

  add_foreign_key "beds", "rooms"
  add_foreign_key "customer_items", "beds"
  add_foreign_key "customer_items", "customers"
  add_foreign_key "customer_items", "rooms"
  add_foreign_key "inventories", "categories"
end
