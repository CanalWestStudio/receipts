module Receipts
  module Concerns
    module DocumentComponents
      DEFAULT_BORDER_COLOR = "aaaaaa"

      # Table styling helpers
      def bordered_cell_style
        {
          borders:
            [:top, :bottom, :left, :right],
            border_color: DEFAULT_BORDER_COLOR,
            inline_format: true,
            padding: 4
        }
      end

      def borderless_cell_style
        {borders: [], border_color: DEFAULT_BORDER_COLOR, inline_format: true, padding: 4}
      end

      def minimal_cell_style
        {borders: [], border_color: DEFAULT_BORDER_COLOR,inline_format: true}
      end

      # Header rendering
      def render_document_header(title, align: :left)
        text title, style: :bold, size: 16, align: align
        move_down 8
      end

      # Two-column section rendering
      def render_two_column_section(left_data:, right_data:, left_title:, right_title:)
        table([
          [{content: "<b>#{left_title}</b>"},
           {content: "<b>#{right_title}</b>"}],
          [left_data, right_data]
        ],
        width: bounds.width,
        column_widths: [bounds.width/2, bounds.width/2],
        cell_style: bordered_cell_style)

        move_down 8
      end

      # Four-column section rendering
      def render_four_column_section(data:, headers:)
        rows = [headers.map { |header| {content: "<b>#{header}</b>"} }]
        rows += data

        table(rows,
          width: bounds.width,
          cell_style: bordered_cell_style)

        move_down 8
      end

      # Single bordered section
      def render_bordered_section(title:, content:)
        table([
          [{content: "<b>#{title}</b>"}],
          [content]
        ],
        width: bounds.width,
        cell_style: bordered_cell_style)

        move_down 8
      end

      # Consolidated certification and signature section
      def render_certification_section(certification:, default_text: nil, text_align: :justify)
        # Use provided text or fallback to default
        certification_text = certification[:text] || default_text

        # Add spacing before certification text if needed
        move_down certification[:spacing_before] if certification[:spacing_before]

        # Render certification text
        text certification_text, align: text_align if certification_text
        move_down 20

        # Render signature if provided
        if certification[:signature_name]
          text "_" * 40, align: :right
          move_down 5
          signature_text = certification[:signature_name]
          signature_text += "  #{certification[:signature_date]}" if certification[:signature_date]
          text signature_text, align: :right, style: :bold, size: 10
          move_down 10
        end

        # Store disclaimer for bottom placement
        @disclaimer = certification[:disclaimer] if certification[:disclaimer]
      end

      # Legacy method for backward compatibility - delegates to render_certification_section
      def render_certification_signature(certification_text:, signature_name: nil, signature_date: nil, disclaimer: nil, text_align: :justify)
        certification_hash = {
          text: certification_text,
          signature_name: signature_name,
          signature_date: signature_date,
          disclaimer: disclaimer
        }
        render_certification_section(certification: certification_hash, text_align: text_align)
      end

      # Page numbering and footer
      def add_page_numbers
        string = "Page <page> of <total>"
        options = {
          at: [bounds.right - 100, bounds.bottom - 10],
          width: 100,
          align: :right,
          size: 8
        }
        number_pages string, options

        add_bottom_disclaimer if @disclaimer
      end

      def add_bottom_disclaimer
        repeat :all do
          bounding_box([bounds.left, bounds.bottom + 30], width: bounds.width, height: 20) do
            text @disclaimer, size: 6, align: :justify
          end
        end
      end

      # Data building helpers
      def build_address_data(data, include_email: false)
        lines = []
        lines << data[:name] if data[:name]
        lines << data[:address] if data[:address]
        lines << data[:city_state_zip] if data[:city_state_zip]
        lines << data[:country] if data[:country]
        lines << data[:phone] if data[:phone]
        lines << data[:email] if data[:email] && include_email
        lines.join("\n")
      end

      def build_company_data(company)
        lines = []
        lines << company[:name] if company[:name]
        lines << company[:address] if company[:address]
        lines << company[:city_state_zip] if company[:city_state_zip]
        lines << company[:country] if company[:country]
        lines << company[:phone] if company[:phone]
        lines << "Tax ID/VAT: #{company[:tax_id]}" if company[:tax_id]
        lines << "EORI: #{company[:eori]}" if company[:eori]
        lines.join("\n")
      end
    end
  end
end