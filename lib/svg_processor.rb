class SVGProcessor
  require "nokogiri"

  def initialize(path, prefix, sprite_path)
    @path = path
    @prefix = prefix
    @sprite_path = sprite_path
  end

  def rebuild
    @svgs = Dir["#{@path}/*"].map { |file| get_svg(file) }
    puts "rebuilding: #{@svgs.length} svgs found"
    @symbols = @svgs.map { |svg| convert_to_symbol(svg) }

    @symbol_string = @symbols.join("\n")

    if @sprite_path != nil
      File.write(@sprite_path, "<svg xmlns=\"http://www.w3.org/2000/svg\">#{@symbol_string}</svg>")
    end
  end

  def to_s
    @symbol_string
  end

  private

  def get_svg(file)
    f = File.open(file)
    doc = Nokogiri::XML(f)
    f.close

    {
      filename: File.basename(file, ".svg"),
      xml: doc
    }
  end

  def convert_to_symbol(svg)
    svg[:xml].xpath('//@id').remove
    g = svg[:xml].at_css("g")
    viewbox_size = svg[:xml].xpath("//@viewBox").first.value
    "<symbol viewBox=\"#{viewbox_size}\" id=\"#{@prefix}#{svg[:filename]}\">#{g.to_s}</symbol>"
  end
end
