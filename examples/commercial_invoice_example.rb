#!/usr/bin/env ruby

require_relative '../lib/receipts'

# Create a commercial invoice with sample data
commercial_invoice = Receipts::CommercialInvoice.new(
  company: {
    name: "Acme Exports Inc.",
    address: "123 Business Park Drive",
    city_state_zip: "Commerce City, CA 90210",
    country: "United States",
    phone: "+1 (555) 123-4567",
    tax_id: "12-3456789",
    eori: "US123456789000"
  },
  recipient: {
    name: "Global Trading Company Ltd.",
    address: "789 International Plaza",
    city_state_zip: "Toronto, ON M5H 2N2",
    country: "Canada",
    email: "orders@globaltrading.ca"
  },
  invoice_details: {
    date: Date.today.strftime("%m/%d/%Y"),
    invoice_no: "CI-2024-0001",
    customer_po: "PO-GT-5678",
    tracking_number: "1Z999AA1234567890"
  },
  trade_details: {
    contents_type: "MERCHANDISE",
    final_destination: "CA",
    export_route: "UPS Worldwide Express",
    packages: "3",
    nondelivery_action: "RTS",
    incoterm: "DAP",
    contents_explanation: "Electronic components and accessories for industrial automation"
  },
  line_items: [
    {
      description: "Industrial sensors and controllers",
      qty: "12",
      net_weight: "8.5 kg",
      tariff_no: "854389",
      eccn: "EAR99",
      origin: "US",
      price: "2,450.00 USD"
    },
    {
      description: "Connecting cables and adapters",
      qty: "25",
      net_weight: "3.2 kg",
      tariff_no: "854442",
      eccn: "EAR99",
      origin: "US",
      price: "750.00 USD"
    }
  ],
  totals: {
    subtotal: "3,200.00 USD",
    total: "3,200.00 USD"
  },
  certification: {
    text: "I hereby certify this commercial invoice to be true and correct.",
    signature_name: "Jane Smith",
    disclaimer: "I certify the particulars given in this customs declaration are correct. This item does not contain any undeclared dangerous articles, or articles prohibited by law or by postal or customs regulations."
  },
  notes: "Please handle with care. Temperature sensitive equipment."
)

# Generate the PDF
commercial_invoice.render_file "examples/commercial_invoice.pdf"

puts "Commercial invoice generated: examples/commercial_invoice.pdf"