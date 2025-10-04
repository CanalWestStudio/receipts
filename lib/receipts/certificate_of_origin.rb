module Receipts
  # CertificateOfOrigin generates official certificates of origin for international trade.
  #
  # This document certifies the country/region where goods were manufactured, produced,
  # or processed. It's required for customs clearance and may be needed for preferential
  # tariff treatment under trade agreements.
  #
  # Example usage:
  #   certificate = CertificateOfOrigin.new(
  #     certifier: {
  #     exporter: "ABC Manufacturing Corp"
  #   },
  #   blanket_period: "1/1/2024 - 12/31/2024",
  #   exporter_details: {
  #     name: "ABC Manufacturing Corp",
  #     address: "123 Industrial Blvd",
  #     city_state_zip: "Springfield IL 62701 USA",
  #     phone: "555-123-4567",
  #     email: "export@abcmfg.com",
  #     tax_id: "12-3456789"
  #   },
  #   producer_details: {
  #     name: "XYZ Components Inc",
  #     address: "456 Factory Lane",
  #     city_state_zip: "Detroit MI 48201 USA",
  #     phone: "555-987-6543",
  #     tax_id: "98-7654321"
  #   },
  #   items: [
  #     {
  #       sku: "PROD-001-BLU",
  #       hs_code: "8421.39",
  #       origin_criterion: "A",
  #       country_of_origin: "US",
  #       description: "Industrial filtration equipment for automotive applications"
  #     }
  #   ],
  #   certification: {
  #     signature_name: "Jane Smith",
  #     signature_date: "March 15, 2024"
  #   }
  # )
  #   certificate.render_file("certificate_of_origin.pdf")
  class CertificateOfOrigin < Base
    include Concerns::DocumentComponents

    DEFAULT_CERTIFICATION_TEXT = "I certify that the goods described in this document qualify as originating and the information contained in this document is true and accurate. I assume responsibility for proving such representations and agree to maintain and present upon request, or to make available during a verification visit, documentation necessary to support this certification."

    @title = "Certificate of Origin"

    def generate_from(attributes)
      return if attributes.empty?

      certifier = attributes.fetch(:certifier, {})
      blanket_period = attributes.fetch(:blanket_period, "")
      exporter_details = attributes.fetch(:exporter_details, {})
      producer_details = attributes.fetch(:producer_details, {})
      items = attributes.fetch(:items, [])
      certification = attributes.fetch(:certification, {})

      # Document header
      render_document_header(title)

      # Certifier and blanket period section
      render_certifier_section(certifier: certifier, blanket_period: blanket_period)

      # Exporter and producer details (two columns)
      render_exporter_producer_section(
        exporter_details: exporter_details,
        producer_details: producer_details
      )

      # Items table
      render_items_section(items: items)

      # Certification section
      render_certification_section(certification: certification)

      # Add page numbers
      add_page_numbers
    end

    private

    def render_certifier_section(certifier:, blanket_period:)
      render_two_column_section(
        left_data: certifier[:certifier_type] || "",
        right_data: blanket_period,
        left_title: "Certifier",
        right_title: "Blanket Period"
      )
    end

    def render_exporter_producer_section(exporter_details:, producer_details:)
      exporter_data = build_company_data(exporter_details)
      producer_data = build_company_data(producer_details)

      render_two_column_section(
        left_data: exporter_data,
        right_data: producer_data,
        left_title: "Exporter Details",
        right_title: "Producer Details"
      )
    end

    def render_items_section(items:)
      return if items.empty?

      headers = ["SKU", "HS Code", "Origin Criterion", "Country of Origin"]

      # Render each item as its own table block
      items.each do |item|
        # Item data row
        item_row = [
          item[:sku] || "",
          item[:hs_code] || "",
          item[:origin_criterion] || "",
          item[:country_of_origin] || ""
        ]

        # Build table rows: headers + item data + description (if present)
        table_rows = [headers.map { |header| {content: "<b>#{header}</b>"} }, item_row]

        # Add description rows if present
        if item[:description]
          table_rows += [
            [{content: "<b>Description</b>", colspan: 4}],
            [{content: item[:description], colspan: 4}]
          ]
        end

        # Create the table for this item
        table(table_rows,
          width: bounds.width,
          cell_style: bordered_cell_style)

        move_down 8
      end
    end

    def render_certification_section(certification:, default_text: DEFAULT_CERTIFICATION_TEXT)
      # Use the consolidated certification section from shared components
      super(
        certification: certification.merge(spacing_before: 20),
        default_text: default_text,
        text_align: :justify
      )
    end
  end
end