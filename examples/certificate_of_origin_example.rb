#!/usr/bin/env ruby

require_relative "../lib/receipts"

certificate = Receipts::CertificateOfOrigin.new(
  certifier: {
    certifier_type: "Exporter"
  },
  blanket_period: "1/1/2024 - 12/31/2024",
  exporter_details: {
    name: "ABC Manufacturing Corp",
    address: "123 Industrial Blvd",
    city_state_zip: "Springfield IL 62701 USA",
    phone: "555-123-4567",
    email: "export@abcmfg.com",
    tax_id: "12-3456789"
  },
  producer_details: {
    name: "XYZ Components Inc",
    address: "456 Factory Lane",
    city_state_zip: "Detroit MI 48201 USA",
    phone: "555-987-6543",
    tax_id: "98-7654321"
  },
    items: [
    {
      sku: "PROD-001-BLU",
      hs_code: "8421.39",
      origin_criterion: "A",
      country_of_origin: "US",
      description: "Industrial filtration equipment for automotive applications"
    },
    {
      sku: "PROD-002-RED",
      hs_code: "8409.91",
      origin_criterion: "B",
      country_of_origin: "US",
      description: "Engine components and spare parts for industrial machinery"
    }
  ],
  certification: {
    signature_name: "Jane Smith",
    signature_date: "March 15, 2024"
  }
)

certificate.render_file("examples/certificate_of_origin_example.pdf")
puts "Certificate of Origin generated: examples/certificate_of_origin_example.pdf"