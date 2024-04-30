require "receipts/version"
require "open-uri"
require "prawn"
require "prawn/table"

module Receipts
  autoload :Base, "receipts/base"
  autoload :Declaration, "receipts/declaration"
  autoload :Invoice, "receipts/invoice"
  autoload :Receipt, "receipts/receipt"
  autoload :PackingSlip, "receipts/packing_slip"
  autoload :Statement, "receipts/statement"

  @@default_font = nil

  # Customize the default font hash
  default_font = {
    bold: Rails.root.join('app/assets/fonts/Inter-Bold.ttf'),
    normal: Rails.root.join('app/assets/fonts/Inter-Regular.ttf')
  }
  def self.default_font=(path)
    @@default_font = path
  end

  def self.default_font
    @@default_font
  end
end
