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

      company = attributes.fetch(:company)
      header company: company, height: attributes.fetch(:logo_height, 16)
      render_details attributes.fetch(:details)
      render_shipping_details recipient: attributes.fetch(:recipient)
      render_line_items attributes.fetch(:line_items)
      render_footer attributes.fetch(:footer, default_message(company: company))
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

    def header(company: {}, height: 48)
      logo = company[:logo]

      grid(0, 0).bounding_box do
        if logo.nil?
          text company.fetch(:name), align: :right, style: :normal, size: 16, color: "4b5563"
        else
          image load_image(logo), width: 48, position: :left
        end
      end

      grid([0, 1], [0, 10]).bounding_box do
        render_billing_details company: company
      end
        
      # move_up height

      text title, style: :normal, size: 16, leading: 4
      text subtitle, style: :normal, size: 12
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
      move_down margin_top

      line_items = [
        [
          {content: Array(recipient).join("\n"), padding: [0, 12, 2, 0]}
        ]
      ]

      text "Ship to", style: :bold, leading: 2      
      table(line_items, width: bounds.width, cell_style: {borders: [], inline_format: true, overflow: :expand})
    end

    def render_line_items(line_items, margin_top: 16)
      move_down margin_top

      borders = line_items.length - 2
      table(line_items, width: 300, cell_style: {border_color: "eeeeee", inline_format: true, overflow: :expand}) do
        cells.padding = 6
        cells.borders = []
        row(0..borders).borders = [:bottom]
      end
    end

    def render_footer(message, margin_top: 30)
      move_down margin_top
      text message, inline_format: true
    end

    def default_message(company:)
      "For questions, contact us anytime at <color rgb='326d92'><link href='mailto:#{company.fetch(:email)}?subject=Question about my receipt'><b>#{company.fetch(:email)}</b></link></color>."
    end
  end
end
