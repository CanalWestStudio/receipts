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
end
