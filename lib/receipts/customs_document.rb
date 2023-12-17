module Receipts
  class CustomsDocument < Base

    def generate_from(attributes)
      return if attributes.empty?

      define_grid(columns: 10, rows: 10, gutter: 10)

      company = attributes.fetch(:company)
      header
      render_details attributes.fetch(:details)
      render_shipping_details recipient: attributes.fetch(:recipient)
      render_line_items attributes.fetch(:line_items)
      render_footer attributes.fetch(:footer, default_message(company: company))
    end

    def header
      text title, style: :normal, size: 16, leading: 4
      text subtitle, style: :normal, size: 12 if subtitle.present?
    end

  end
end
