# frozen_string_literal: true

module Jekyll
  module SVGSprite
    VALID_SYNTAX = /(\w+)\s*=\s*(?:"([^"\\]*(?:\\.[^"\\]*)*)"|'([^'\\]*(?:\\.[^'\\]*)*)'|([\w.-]+))/x

    # Method to initialize SVG attributes and parse markup
    def self.parse_markup(markup)
      attributes = {}
      markup.scan(VALID_SYNTAX) do |key, d_quoted, s_quoted, variable|
        value = if d_quoted
                  d_quoted.include?('\\"') ? d_quoted.gsub('\\"', '"') : d_quoted
                elsif s_quoted
                  s_quoted.include?("\\'") ? s_quoted.gsub("\\'", "'") : s_quoted
                elsif variable
                  variable.strip # Handle variable names passed directly
                end
        attributes[key] = value if key
      end
      attributes
    end

    def self.render_svg(context, attributes)
      svg_id = attributes['id'] || ''

      # Resolve the variable if it exists in the context
      svg_id = context[svg_id] if context[svg_id].is_a?(String)
      return '' if svg_id.nil? || svg_id.empty?

      site = context.registers[:site]
      baseurl = site.config['baseurl'] || ''
      svg_base = File.join('assets', 'icons.svg')
      svg_path = File.join(site.source, svg_base)

      raise "SVG sprite file not found: '#{svg_path}'" unless File.exist?(svg_path)

      svg_url = File.join(baseurl, svg_base)
      svg_path_with_id = "#{svg_url}##{svg_id}".downcase

      svg_attrs = {
        'xmlns' => 'http://www.w3.org/2000/svg',
        'xmlns:xlink' => 'http://www.w3.org/1999/xlink',
        'width' => '24',
        'height' => '24',
        'viewBox' => '0 0 24 24',
        'aria-hidden' => 'true'
      }

      attributes.each do |key, value|
        next if %w[id xmlns xmlns:xlink aria-hidden].include?(key)

        svg_attrs[key] = value
      end

      svg_attrs_string = svg_attrs.map { |k, v| "#{k}=\"#{v}\"" }.join(' ')
      %(<svg #{svg_attrs_string}><use xlink:href="#{svg_path_with_id}" /></svg>)
    end
  end

  class SVGSpriteTag < Liquid::Tag
    def initialize(tag_name, markup, tokens)
      super
      @attributes = SVGSprite.parse_markup(markup)
    end

    def render(context)
      SVGSprite.render_svg(context, @attributes)
    end
  end
end

Liquid::Template.register_tag('svg_sprite', Jekyll::SVGSpriteTag)
