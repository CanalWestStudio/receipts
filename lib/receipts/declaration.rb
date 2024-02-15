module Receipts
  class Declaration < Base
    @title = "Customs Document"

    def generate_from(attributes)
      return if attributes.empty?

      header

      define_grid(columns: 10, rows: 10, gutter: 10)

      sub_line_items ||= attributes.fetch(:sub_line_items)

      render_details attributes.fetch(:details)
      render_shipping_details attributes.fetch(:recipients)
      render_line_items attributes.fetch(:line_items)
      render_sub_line_items(sub_line_items) if sub_line_items.present?

      render_footer attributes.fetch(:footer)
    end



    def render_footer(message)
      if message.present?
        # move_down 32
        vertical_line y + 30, bounds.top - 55, at: 0
        vertical_line y + 30, bounds.top - 55, at: bounds.width
        render_footer_stroke
        move_down 30
      end

      indent(6, 6) do
        text message, inline_format: true
      end
    end
  end
end
