module Receipts
  class Base < Prawn::Document
    attr_accessor :title, :subtitle, :company

    class << self
      attr_reader :title, :subtitle
    end

    def initialize(attributes = {})
      super page_size: attributes.delete(:page_size) || "LETTER"
      setup_fonts attributes.fetch(:font, Receipts.default_font)

      @title = attributes.fetch(:title, self.class.title)
      @subtitle = attributes.fetch(:subtitle, self.class.subtitle)

      generate_from(attributes)
    end

    def generate_from(attributes)
      return if attributes.empty?

      define_grid(columns: 10, rows: 10, gutter: 10)

      company ||= attributes.fetch(:company)
      render_company(company: company) if company.present?

      header
      render_details attributes.fetch(:details)
      render_shipping_details recipient: attributes.fetch(:recipient)
      render_line_items attributes.fetch(:line_items)
      render_footer attributes.fetch(:footer)
    end

    def setup_fonts(custom_font = nil)
      if !!custom_font
        font_families.update "Primary" => custom_font
        font "Primary"
      end

      font_size 8
    end

    def load_image(logo)
      if logo.is_a? String
        logo.start_with?("http") ? URI.parse(logo).open : File.open(logo)
      else
        logo
      end
    end

    def render_company(company:)
      logo = company[:logo]

      if logo.present?
        grid(0, 0).bounding_box do
          image load_image(logo), width: 36, position: :left
        end
      end


      grid([0, 1], [0, 10]).bounding_box do
        render_billing_details company: company
      end
    end

    def header
      text title, style: :normal, size: 16, leading: 4
      text subtitle, style: :normal, size: 12 if subtitle.present?
    end

    def render_details(details, margin_top: 16)
      move_down margin_top
      table(details, cell_style: {borders: [], inline_format: true, padding: [0, 48, 2, 0]})
    end

    def render_billing_details(company:, margin_top: 4)
      company_details = [
        company[:address],
        company[:phone],
        company[:email]
      ].compact.join("\n")

      line_items = [
        [
          {content: "<b>#{company.fetch(:name)}</b>\n#{company_details}", padding: [0, 12, 2, 12]}
        ]
      ]
      table(line_items, width: bounds.width, cell_style: {borders: [], inline_format: true, overflow: :expand})
    end

    def render_shipping_details(recipient:, margin_top: 16)
      margin_top

      line_items = [
        [
          {content: Array(recipient).join("\n"), padding: [0, 12, 2, 0]}
        ]
      ]
     
      table(line_items, cell_style: {borders: [], inline_format: true, padding: [0, 24, 2, 0]})
    end

    def render_line_items(line_items, margin_top: 16)
      move_down margin_top

      borders = line_items.length - 2
      table(line_items, width: bounds.width, column_widths: {0 => 320}, cell_style: {border_color: "e5e5e5", inline_format: true, overflow: :expand}) do
        cells.padding = 6
        cells.borders = []

        # column(-1).width = 8
        # column(-1).style(align: :right)

        row(0..borders).borders = [:bottom]
      end
    end

    def render_footer(message, margin_top: 30)
      margin_top

      render_footer_stroke if message.present?

      text message, inline_format: true
    end

    def render_footer_stroke
      move_down 60

      stroke do
        line_width 1
        move_down 30
        stroke_color 'd4d4d4'
        stroke_horizontal_rule
      end

      move_down 30
    end

    def default_message
      ""
    end
  end
end
