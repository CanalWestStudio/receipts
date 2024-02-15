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

      stroke do
        rectangle [bounds.left, bounds.top - 200], bounds.width, bounds.top - 200
      end
    end

    def render_shipping_details(recipients, margin_top: 24)
      move_down margin_top

      table(recipients, column_widths: {0 => 180, 1 => 180, 2 => 180}, cell_style: {border_color: "cccccc", inline_format: true, padding: [2, 24, 2, 2]})
    end

    def render_line_items(line_items, margin_top: 30)
      move_down margin_top

      borders = line_items.length - 2
      table(line_items, width: bounds.width, cell_style: {border_color: "eeeeee", inline_format: true}) do
        cells.padding = 6

        column(0).max_width = 240
        column(-1).style align: :right
      end
    end

    def render_footer(message, margin_top: 32)
      margin_top

      render_footer_stroke if message.present?
      indent(6, 6) do
        text message, inline_format: true
      end
    end
  end
end
