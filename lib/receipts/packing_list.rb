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

    @title = "Packing List"

    def generate_from(attributes)
      return if attributes.empty?

      company = attributes.fetch(:company, {})
      logo = attributes[:logo]
      record_number = attributes.fetch(:record_number, "")
      shipping_details = attributes.fetch(:shipping_details, {})
      shipping_address = attributes.fetch(:shipping_address, {})
      items = attributes.fetch(:items, [])

      # Letterhead with logo and company info using shared component
      render_letterhead(company: company, logo: logo)

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



    def render_title_section(record_number:)
      text title, style: :bold, size: 16, align: :left
      move_down 5
      text "Invoice #{record_number}", size: 12, align: :left if record_number && !record_number.empty?
      move_down 20
    end

    def render_shipping_details_section(shipping_details:)
      headers = ["Order date", "Shipping method", "Dimensions", "Weight"]
      data = [
        shipping_details[:order_date] || "",
        shipping_details[:shipping_method] || "",
        shipping_details[:dimensions] || "",
        shipping_details[:weight] || ""
      ]

      render_four_column_section(data: [data], headers: headers)
    end

        def render_shipping_address_section(shipping_address:)
      address_data = build_address_data(shipping_address)

      # Render without borders
      move_down 10
      text "<b>Shipping Address</b>", inline_format: true
      move_down 5
      text address_data
      move_down 20
    end

    def render_items_section(items:)
      return if items.empty?

      # Header row with bottom border only
      table([
        [{content: "<b>Items</b>"}, {content: "<b>Quantity</b>", align: :right}]
      ],
      width: bounds.width,
      column_widths: [bounds.width - 80, 80],
      cell_style: {borders: [:bottom], border_color: DEFAULT_BORDER_COLOR, inline_format: true, padding: 4})

      # Items rows without borders
      items.each do |item|
        table([
          [item[:description] || "", {content: item[:quantity] || "", align: :right}]
        ],
        width: bounds.width,
        column_widths: [bounds.width - 80, 80],
        cell_style: borderless_cell_style)
      end

      move_down 8
    end

    # Helper methods are now in shared DocumentComponents concern
  end
end