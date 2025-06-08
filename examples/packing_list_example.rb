#!/usr/bin/env ruby

require_relative "../lib/receipts"

packing_list = Receipts::PackingList.new(
  company: {
    name: "ABC Manufacturing Corp",
    address: "123 Industrial Blvd Suite 100",
    city_state_zip: "Springfield IL 62701 USA",
    phone: "555-123-4567",
    email: "shipping@abcmfg.com"
  },
  # logo: nil, # Logo is optional and handled gracefully
  record_number: "1884",
  shipping_details: {
    order_date: "May 22, 2025",
    shipping_method: "FedEx Ground",
    dimensions: "33.0 x 12.0 x 16.0 in",
    weight: "28.0 lb"
  },
  shipping_address: {
    name: "Ricky's Bakery",
    address: "123 Main Street",
    address2: "Suite 100",
    city_state_zip: "Dartmouth NS B2Y 4P9 CAN",
    phone: "(281) 330-8004"
  },
  items: [
    {
      description: "Widget",
      quantity: "4"
    },
    {
      description: "Industrial Safety Gloves - Medium",
      quantity: "2"
    }
  ]
)

packing_list.render_file("examples/packing_list_example.pdf")
puts "Packing List generated: examples/packing_list_example.pdf"