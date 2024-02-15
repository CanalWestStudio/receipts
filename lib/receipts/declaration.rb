module Receipts
  class Declaration < Base
    @title = "Customs Document"

    def generate_from(attributes)
      return if attributes.empty?

      define_grid(columns: 10, rows: 10, gutter: 10)

      sub_line_items ||= attributes.fetch(:sub_line_items)

      header
      render_details attributes.fetch(:details)
      render_shipping_details attributes.fetch(:recipients)
      render_line_items attributes.fetch(:line_items)
      render_sub_line_items(sub_line_items) if sub_line_items.present?
      render_footer attributes.fetch(:footer)
    end
  end
end
