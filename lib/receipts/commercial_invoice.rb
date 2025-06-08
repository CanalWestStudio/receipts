module Receipts
  # CommercialInvoice generates professional commercial invoices for international trade.
  #
  # This document type includes all required fields for customs and trade compliance:
  # - Shipper/Exporter and Recipient information
  # - Import/Export trade details (Contents Type, BOL/AWB, AES/ITN, etc.)
  # - Line items with tariff numbers, ECCN codes, and origin details
  # - Totals and certification sections
  #
  # Example usage:
  #   invoice = CommercialInvoice.new(
  #     company: { name: "Exporter Inc", address: "123 St", country: "US" },
  #     recipient: { name: "Importer Ltd", address: "456 Ave", country: "CA" },
  #     invoice_details: { date: "2024-01-15", invoice_no: "CI-001" },
  #     trade_details: { contents_type: "MERCHANDISE", final_destination: "CA" },
  #     line_items: [{ description: "Product", qty: "1", price: "100.00 USD" }],
  #     totals: { total: "100.00 USD" },
  #     certification: { signature_name: "John Doe" }
  #   )
  #   invoice.render_file("commercial_invoice.pdf")
  class CommercialInvoice < Base
    @title = "Commercial Invoice"

    def generate_from(attributes)
      return if attributes.empty?

      company = attributes.fetch(:company)
      recipient = attributes.fetch(:recipient, {})
      invoice_details = attributes.fetch(:invoice_details, {})
      trade_details = attributes.fetch(:trade_details, {})
      line_items = attributes.fetch(:line_items, [])
      totals = attributes.fetch(:totals, {})
      certification = attributes.fetch(:certification, {})

      # Main header with title
      render_header_section

      # Top row with invoice details
      render_invoice_details_section(invoice_details: invoice_details)

      # Second row with shipper, recipient, and importer
      render_shipper_recipient_importer_section(company: company, recipient: recipient, trade_details: trade_details)

      # Import/Export details section
      render_import_export_section(trade_details: trade_details)

      # Notes section if provided
      render_notes_section(attributes[:notes]) if attributes[:notes]

      # Line items section
      render_line_items_section(line_items: line_items)

      # Totals section
      render_totals_section(totals: totals)

      # Certification section
      render_certification_section(certification: certification)

      # Add page numbers
      add_page_numbers
    end

    private

    def render_header_section
      text title, style: :bold, size: 16, align: :left
      move_down 8
    end

    def render_invoice_details_section(invoice_details:)
      invoice_data = build_invoice_data(invoice_details)

      table([
        [{content: "<b>Date</b>"},
         {content: "<b>Invoice No.</b>"},
         {content: "<b>Customer PO No.</b>"},
         {content: "<b>Tracking Number</b>"}],
        [invoice_data[:date] || "",
         invoice_data[:invoice_no] || "",
         invoice_data[:customer_po] || "",
         invoice_data[:tracking_number] || ""]
      ],
      width: bounds.width,
      cell_style: bordered_cell_style)

      move_down 8
    end

    def render_shipper_recipient_importer_section(company:, recipient:, trade_details:)
      shipper_data = build_shipper_data(company)
      recipient_data = build_recipient_data(recipient)

      table([
        [{content: "<b>Shipper/Exporter</b>"},
         {content: "<b>Recipient/Ship To</b>"},
         {content: "<b>Importer of Record</b>"}],
        [shipper_data,
         recipient_data,
         trade_details[:import_of_record] || "(if other than Recipient)"]
      ],
      width: bounds.width,
      column_widths: [bounds.width/3, bounds.width/3, bounds.width/3],
      cell_style: bordered_cell_style)

      move_down 8
    end

    def render_import_export_section(trade_details:)
      # Import/export details section with outer border only
      details_rows = [
        [{content: "<b>Contents Type</b>"},
         {content: "<b>BOL / AWB No.</b>"},
         {content: "<b>Final Destination</b>"},
         {content: "<b>Export Route / Carrier</b>"},
         {content: "<b>No. of Packages</b>"}],
        [trade_details[:contents_type] || "MERCHANDISE",
         trade_details[:bl_awb_no] || "",
         trade_details[:final_destination] || "",
         trade_details[:export_route] || "",
         trade_details[:packages] || "1"],

        [{content: "<b>AES / ITN</b>"},
         {content: "<b>EEL / PFC</b>"},
         {content: "<b>Exporter Ref</b>"},
         {content: "<b>Importer Ref</b>"},
         {content: "<b>License</b>"}],
        [trade_details[:aes_itn] || "",
         trade_details[:eei_pfc] || "",
         trade_details[:exporter_ref] || "",
         trade_details[:importer_ref] || "",
         trade_details[:license] || ""],

        [{content: "<b>Certificate</b>"},
         {content: "<b>Nondelivery Action</b>"},
         {content: "<b>Incoterm</b>"},
         {content: "<b>B13A Option</b>"},
         {content: "<b>B13A Number</b>"}],
        [trade_details[:certificate] || "",
         trade_details[:nondelivery_action] || "RTS",
         trade_details[:incoterm] || "DDU",
         trade_details[:b13a_option] || "",
         trade_details[:b13a_number] || ""],

        [{content: "<b>Contents Explanation</b>", colspan: 5}],
        [{content: trade_details[:contents_explanation] || "", colspan: 5}]
      ]

      table(details_rows,
        width: bounds.width,
        cell_style: borderless_cell_style) do
        # Add only outer border - no internal borders at all
        cells.borders = []
        # First row - top border
        cells[0,0].borders = [:top, :left]
        cells[0,1].borders = [:top]
        cells[0,2].borders = [:top]
        cells[0,3].borders = [:top]
        cells[0,4].borders = [:top, :right]

        # Middle rows - only left and right borders on edge cells
        (1..5).each do |i|
          cells[i,0].borders = [:left]
          cells[i,4].borders = [:right]
        end

        # Contents Explanation rows (they span all columns)
        cells[6,0].borders = [:left, :right]  # Contents Explanation header spans all 5 columns
        cells[7,0].borders = [:left, :right, :bottom]  # Contents Explanation data spans all 5 columns
      end

      move_down 8
    end

    def render_notes_section(notes)
      table([
        [{content: "<b>Notes</b>"}],
        [notes]
      ],
      width: bounds.width,
      cell_style: bordered_cell_style)

      move_down 8
    end

    def render_line_items_section(line_items:)
      return if line_items.empty?

      # Header row for line items
      header_row = [
        {content: "<b>List of Items</b>", colspan: 7}
      ]

      column_headers = [
        {content: "<b>Description</b>"},
        {content: "<b>Qty</b>"},
        {content: "<b>Net Weight</b>"},
        {content: "<b>Tariff No.</b>"},
        {content: "<b>ECCN</b>"},
        {content: "<b>Origin</b>"},
        {content: "<b>Price</b>"}
      ]

      rows = [header_row, column_headers]

      # Add line items
      line_items.each do |item|
        rows << [
          item[:description] || "",
          item[:qty] || "",
          item[:net_weight] || "",
          item[:tariff_no] || "",
          item[:eccn] || "",
          item[:origin] || "",
          item[:price] || ""
        ]
      end

      table(rows,
        width: bounds.width,
        cell_style: borderless_cell_style) do
        # Add outer border and horizontal dividers
        cells.borders = []
        # Header borders with outer border
        row(0).borders = [:top, :left, :right, :bottom]  # "List of Items" header
        row(1).borders = [:left, :right, :bottom]         # Column headers

        # Side borders for all data rows
        (2...rows.length).each do |i|
          if i == rows.length - 1
            row(i).borders = [:left, :right, :bottom]     # Last row gets bottom border
          else
            row(i).borders = [:left, :right]              # Middle rows get side borders
          end
        end
      end

      move_down 8
    end

    def render_totals_section(totals:)
      subtotal = totals[:subtotal] || ""
      total = totals[:total] || ""

      # Create a table that aligns with the line items table
      totals_table = [
        ["", "", "", "", "", "", "", "Subtotal", subtotal],
        ["", "", "", "", "", "", "", "<b>Total:</b>", "<b>#{total}</b>"]
      ]

      table(totals_table,
        width: bounds.width,
        cell_style: minimal_cell_style) do
        cells.align = :right
      end

      move_down 20
    end

    def render_certification_section(certification:)
      certification_text = certification[:text] ||
        "I hereby certify this commercial invoice to be true and correct."

      text certification_text, align: :center
      move_down 20

      if certification[:signature_name]
        text "_" * 40, align: :right
        move_down 5
        text certification[:signature_name], align: :right, style: :bold
        move_down 10
      end

      # Store disclaimer for bottom placement
      @disclaimer = certification[:disclaimer] if certification[:disclaimer]
    end

    def add_page_numbers
      # Add page numbers to all pages
      string = "Page <page> of <total>"
      options = {
        at: [bounds.right - 100, bounds.bottom - 10],
        width: 100,
        align: :right,
        size: 8
      }
      number_pages string, options

      # Add disclaimer at bottom if present
      add_bottom_disclaimer if @disclaimer
    end

    def add_bottom_disclaimer
      # Position disclaimer at bottom left of page
      repeat :all do
        bounding_box([bounds.left, bounds.bottom + 30], width: bounds.width - 110, height: 20) do
          text @disclaimer, size: 6, overflow: :shrink_to_fit
        end
      end
    end

    # Helper methods for table styling
    def bordered_cell_style
      {borders: [:top, :bottom, :left, :right], inline_format: true, padding: 4}
    end

    def borderless_cell_style
      {borders: [], inline_format: true, padding: 4}
    end

    def minimal_cell_style
      {borders: [], inline_format: true}
    end

    # Helper methods for building data sections
    def build_shipper_data(company)
      shipper_lines = []
      shipper_lines << company[:name] if company[:name]
      shipper_lines << company[:address] if company[:address]
      shipper_lines << company[:city_state_zip] if company[:city_state_zip]
      shipper_lines << company[:country] if company[:country]
      shipper_lines << company[:phone] if company[:phone]
      shipper_lines << "Tax ID/VAT: #{company[:tax_id]}" if company[:tax_id]
      shipper_lines << "EORI: #{company[:eori]}" if company[:eori]
      shipper_lines.join("\n")
    end

    def build_recipient_data(recipient)
      recipient_lines = []
      recipient_lines << recipient[:name] if recipient[:name]
      recipient_lines << recipient[:address] if recipient[:address]
      recipient_lines << recipient[:city_state_zip] if recipient[:city_state_zip]
      recipient_lines << recipient[:country] if recipient[:country]
      recipient_lines << recipient[:email] if recipient[:email]
      recipient_lines.join("\n")
    end

    def build_invoice_data(invoice_details)
      {
        date: invoice_details[:date],
        invoice_no: invoice_details[:invoice_no],
        customer_po: invoice_details[:customer_po],
        tracking_number: invoice_details[:tracking_number]
      }
    end
  end
end