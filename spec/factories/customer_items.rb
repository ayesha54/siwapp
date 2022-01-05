FactoryBot.define do
  factory :customer_item do
    room { nil }
    bed { nil }
    quantity { "9.99" }
    discount { "9.99" }
    description { "MyString" }
    net_amount { 1.5 }
    tax { 1 }
    unitary_cost { "9.99" }
  end
end
