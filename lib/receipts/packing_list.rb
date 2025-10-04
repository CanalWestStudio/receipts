module Receipts
  # PackingList generates professional packing lists for shipment documentation.
  #
  # A packing list provides detailed information about the contents of a shipment,
  # including item descriptions, quantities, dimensions, and weight. It's used by
  # shipping companies, customs authorities, and receivers to verify shipment contents.
  #
  # Example usage:
  #   packing_list = PackingList.new(
  #     company: {
  #       name: "ABC Manufacturing Corp",
  #       address: "123 Industrial Blvd",
  #       city_state_zip: "Springfield IL 62701 USA",
  #       phone: "555-123-4567",
  #       email: "shipping@abcmfg.com"
  #     },
  #     logo: "path/to/logo.png", # optional
  #     record_number: "1884",
  #     shipping_details: {
  #       order_date: "May 22, 2025",
  #       shipping_method: "FedEx Ground",
  #       dimensions: "33.0 x 12.0 x 16.0 in",
  #       weight: "28.0 lb"
  #     },
  #     shipping_address: {
  #       name: "Flynn Canada - Halifax",
  #       address: "123 Main Street",
  #       address2: "Suite 100",
  #       city_state_zip: "Toronto ON B2Y 4P9 CAN",
  #       phone: "(281) 330-8004"
  #     },
  #     items: [
  #       {
  #         description: "Widget",
  #         quantity: "4"
  #       }
  #     ]
  #   )
  #   packing_list.render_file("packing_list.pdf")
  class PackingList < Base
    include Concerns::DocumentComponents

    module Defaults
      HEADERS = ['Order date', 'Shipping method', 'Dimensions', 'Weight']
      ITEMS_TITLE = '<b>Items</b>'
      QUANTITY_TITLE = '<b>Quantity</b>'
      SCAN_LABEL = 'Scan to confirm shipped'
      SHIPPING_ADDRESS_TITLE = '<b>Shipping Address</b>'
    end

    @title = 'Packing List'

    def generate_from(attributes)
      return if attributes.empty?

      company = attributes.fetch(:company, {})
      # Support both logo as top-level parameter and as part of company hash
      logo = attributes[:logo] || company[:logo]
      record_number = attributes.fetch(:record_number, '')
      shipping_details = attributes.fetch(:shipping_details, {})
      shipping_address = attributes.fetch(:shipping_address, {})
      items = attributes.fetch(:items, [])
      qr_code = attributes[:qr_code]

      # Letterhead with logo, company info, and QR code using shared component
      render_letterhead_with_qr(company: company, logo: logo, qr_code: qr_code)

      # Document title and invoice number
      render_title_section(record_number: record_number)

      # Shipping details (4-column section)
      render_shipping_details_section(shipping_details: shipping_details)

      # Shipping address
      render_shipping_address_section(shipping_address: shipping_address)

      # Items section
      render_items_section(items: items)
    end

    private

    def render_letterhead_with_qr(company:, logo: nil, qr_code: nil)
      # Check if logo exists (either as local file or URL)
      logo_exists = if logo
                      if logo.start_with?('http')
                        true # Assume URL is valid
                      else
                        File.exist?(logo)
                      end
                    else
                      false
                    end

      if valid_qr_code?(qr_code)
        # Render using float to position QR code on right
        float do
          bounding_box([bounds.width - 90, cursor], width: 90, height: 100) do
            png_data = qr_code[:png].to_blob
            image StringIO.new(png_data), width: 70, height: 70, position: :right

            # Use custom label if provided, otherwise default
            qr_label = qr_code[:label] || Defaults::SCAN_LABEL
            text qr_label, size: 6, align: :right, color: '666666'

            if qr_code[:url]
              move_down 2
              url_display = qr_code[:url].gsub(%r{https?://}, '').split('/').first
              text url_display, size: 5, align: :right, color: '999999'
            end
          rescue StandardError
            # Skip QR if error
          end
        end

        # Render letterhead on left
        bounding_box([0, cursor], width: bounds.width - 100) do
          if logo && logo_exists
            begin
              image load_image(logo), fit: [120, 30], position: :left
            rescue StandardError
              text '', size: 12, align: :left, style: :bold
            end
            move_down 5
          end
          text build_company_letterhead(company), align: :left, inline_format: true
        end
      else
        # No QR code, just render letterhead normally
        if logo && logo_exists
          begin
            image load_image(logo), fit: [120, 30], position: :left
          rescue StandardError
            text '', size: 12, align: :left, style: :bold
          end
          move_down 5
        end
        text build_company_letterhead(company), align: :left, inline_format: true
      end

      move_down 15
    end

    def render_title_section(record_number:)
      text title, style: :bold, size: 16, align: :left
      move_down 5
      text "#{record_number}", size: 12, align: :left if record_number && !record_number.empty?
      move_down 20
    end

    def render_shipping_details_section(shipping_details:)
      headers = Defaults::HEADERS
      data = [
        shipping_details[:order_date] || '',
        shipping_details[:shipping_method] || '',
        shipping_details[:dimensions] || '',
        shipping_details[:weight] || ''
      ]

      render_four_column_section(data: [data], headers: headers)
    end

    def render_shipping_address_section(shipping_address:)
      address_data = build_address_data(shipping_address)

      # Render without borders
      move_down 10
      text Defaults::SHIPPING_ADDRESS_TITLE, inline_format: true
      move_down 5
      text address_data
      move_down 20
    end

    def render_items_section(items:)
      return if items.empty?

      # Header row with bottom border only
      table([
              [{ content: Defaults::ITEMS_TITLE }, { content: Defaults::QUANTITY_TITLE, align: :right }]
            ],
            width: bounds.width,
            column_widths: [bounds.width - 80, 80],
            cell_style: { borders: [:bottom], border_color: DEFAULT_BORDER_COLOR, inline_format: true, padding: 4 })

      # Items rows without borders
      items.each do |item|
        table([
                [item[:description] || '', { content: item[:quantity] || '', align: :right }]
              ],
              width: bounds.width,
              column_widths: [bounds.width - 80, 80],
              cell_style: borderless_cell_style)
      end

      move_down 8
    end

    def valid_qr_code?(qr_code)
      qr_code.present? && qr_code.is_a?(Hash) && qr_code[:png].present?
    end
  end
end
