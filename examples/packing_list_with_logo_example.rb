#!/usr/bin/env ruby

require_relative "../lib/receipts"

# Test with invalid logo path (should gracefully fallback)
packing_list = Receipts::PackingList.new(
  company: {
    name: "ABC Manufacturing Corp",
    address: "123 Industrial Blvd Suite 100",
    city_state_zip: "Springfield IL 62701 USA",
    phone: "555-123-4567",
    email: "shipping@abcmfg.com"
  },
  logo: "path/to/nonexistent/logo.png", # This should be handled gracefully
  record_number: "1885",
  shipping_details: {
    order_date: "May 23, 2025",
    shipping_method: "UPS Ground",
    dimensions: "24.0 x 8.0 x 12.0 in",
    weight: "15.5 lb"
  },
  shipping_address: {
    name: "Test Customer Inc",
    address: "456 Business Ave",
    city_state_zip: "Toronto ON M5V 3A8 CAN",
    phone: "(416) 555-0123"
  },
  items: [
    {
      description: "Test Product A",
      quantity: "3"
    }
  ]
)

packing_list.render_file("examples/packing_list_with_logo_example.pdf")
puts "Packing List with logo test generated: examples/packing_list_with_logo_example.pdf"
puts "(Logo path was invalid, document should render without logo)"