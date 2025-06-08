# frozen_string_literal: true

require "test_helper"

class TestReceipts < Minitest::Test
  def test_without_arguments
    assert_instance_of Receipts::Receipt, Receipts::Receipt.new
  end

  def test_customization
    assert Receipts::Receipt.new.respond_to?(:text)
  end

  def test_renderable
    assert Receipts::Receipt.new.respond_to?(:render_file)
  end

  def test_receipt_with_arguments
    assert_instance_of Receipts::Receipt, Receipts::Receipt.new(
      company: {
        name: "Company",
        address: "123 Street",
        email: "company@example.org"
      },
      recipient: [],
      details: [
        ["Receipt", "123"]
      ],
      line_items: [
        ["Product", "$10"]
      ]
    )
  end

  def test_invoice_with_arguments
    assert_instance_of Receipts::Invoice, Receipts::Invoice.new(
      company: {
        name: "Company",
        address: "123 Street",
        email: "company@example.org"
      },
      recipient: [],
      details: [
        ["Receipt", "123"]
      ],
      line_items: [
        ["Product", "$10"]
      ]
    )
  end

  def test_statement_with_arguments
    assert_instance_of Receipts::Statement, Receipts::Statement.new(
      company: {
        name: "Company",
        address: "123 Street",
        email: "company@example.org"
      },
      recipient: [],
      details: [
        ["Receipt", "123"]
      ],
      line_items: [
        ["Product", "$10"]
      ]
    )
  end

  def test_commercial_invoice_with_arguments
    assert_instance_of Receipts::CommercialInvoice, Receipts::CommercialInvoice.new(
      company: {
        name: "Acme Corporation",
        address: "123 Export St",
        city_state_zip: "Export City, TX 12345",
        country: "US",
        phone: "555-123-4567",
        tax_id: "123456789",
        eori: "US123456789"
      },
      recipient: {
        name: "Global Imports Ltd",
        address: "456 Import Ave",
        city_state_zip: "Import Town, ON K1A 0A6",
        country: "CA"
      },
      invoice_details: {
        date: "2024-01-15",
        invoice_no: "CI-2024-001",
        customer_po: "PO-12345",
        tracking_number: "TRK123456789"
      },
      trade_details: {
        contents_type: "MERCHANDISE",
        final_destination: "CA",
        export_route: "Air Express",
        packages: "2",
        nondelivery_action: "RTS",
        incoterm: "CIF"
      },
      line_items: [
        {
          description: "Sample Product A",
          qty: "10",
          net_weight: "5.5 kg",
          tariff_no: "123456",
          origin: "US",
          price: "100.00 USD"
        }
      ],
      totals: {
        subtotal: "100.00 USD",
        total: "100.00 USD"
      },
      certification: {
        text: "I hereby certify this commercial invoice to be true and correct.",
        signature_name: "John Doe",
        disclaimer: "This is a test disclaimer for commercial invoice purposes."
      }
    )
  end

  def test_certificate_of_origin_with_arguments
    assert_instance_of Receipts::CertificateOfOrigin, Receipts::CertificateOfOrigin.new(
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
  end
end
