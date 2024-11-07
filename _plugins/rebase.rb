# frozen_string_literal: true

require 'nokogiri'
require_relative 'svg_sprite'

module Jekyll
  module RebaseContent
    def page_modified(input)
      @site = @context.registers[:site]
      metadata = @site.data['metadata'] || {}

      # Parsing fragment and applying transformations
      fragment = fragment_element(input)
      fragment = parse_alerts(fragment, metadata['alerts'])
      fragment = parse_codes(fragment, metadata['codes'])
      fragment = parse_task_list(fragment)

      fragment.to_html
    end

    private

    # Helper method to create a new HTML element
    def create_element(tag, doc)
      doc ||= Nokogiri::HTML::Document.new
      Nokogiri::XML::Node.new(tag, doc)
    end

    # Helper method to create a document fragment from HTML input
    def fragment_element(doc)
      Nokogiri::HTML::DocumentFragment.parse(doc)
    end

    # Check if the text input is an HTML element
    def html_element?(text)
      doc = fragment_element(text)
      element = doc.children.first
      element && element.node_type == Nokogiri::XML::Node::ELEMENT_NODE
    end

    # Parse and enhance alert elements
    def parse_alerts(doc, config)
      doc.css('.alert')&.each do |node|
        type = node['class'].match(/alert-(\w+)/)&.captures&.first

        # Set default values, then override if a specific type exists
        alert_data = config[type] || config['default'] || {}
        alert_icon = create_element('span', doc)
        alert_icon['class'] = 'alert-icon'
        alert_icon.add_child(SVGSprite.render_svg(@context, { 'id' => alert_data['icon'], 'class' => 'icon' }))

        alert_name = create_element('span', doc)
        alert_name['class'] = 'alert-name'
        alert_name.content = alert_data['name']

        alert_title = create_element('span', doc)
        alert_title['class'] = 'alert-header'
        alert_title.add_child(alert_icon)
        alert_title.add_child(alert_name)

        alert_content = create_element('div', doc)
        alert_content['class'] = 'alert-content'
        alert_content.inner_html = node.inner_html

        node.name = 'div'
        node.inner_html = "#{alert_title}#{alert_content}"
        node.set_attribute('role', 'alert')
        node.set_attribute('data-type', alert_data['type']) if !node['data-type'] && alert_data['type']
      end
      doc
    end

    # Parse and enhance code blocks
    def parse_codes(doc, config)
      doc.css('figure.highlight')&.each do |node|
        code_inner = node.at_css('pre code').inner_html
        data_lang = node.at_css('pre code')['data-lang']
        new_node = create_element('div', doc)
        node.attributes.each { |name, attr| new_node[name] = attr.value }
        new_node.remove_class('highlight')
        new_node.append_class("language-#{data_lang} highlighter-rouge")
        new_node.inner_html = %(<pre class="highlight"><code data-lang="#{data_lang}">#{code_inner}</code></pre>)
        node.replace(new_node)
      end

      doc = parse_mark_lines(doc)

      doc.css('[class*="language-"]')&.each do |node|
        language = node['class'].match(/language-(\S+)/).captures.first
        code_table = node.at_css('table:has(td pre)')
        next unless code_table

        code_icon = ''
        code_name = language

        config['languages'].each do |lang|
          next unless lang['alias'].include?(language)

          code_icon = SVGSprite.render_svg(@context, { 'id' => lang['icon'], 'class' => 'icon' })
          code_name = lang['name']
          break
        end

        code_title = create_element('span', doc)
        code_title['class'] = 'code-header__title'
        code_title['data-name'] = code_name
        code_title.add_child(code_icon) if code_icon

        data_button = config['buttons'] || {
          copy: { name: 'Copy', icon: '' },
          success: { name: 'Copied', icon: '' },
          error: { name: 'Error!', icon: '' }
        }

        code_action = create_element('button', doc)
        code_action['type'] = 'button'
        code_action['class'] = 'code-header__button'
        code_action['aria-label'] = "Copy #{code_name} code to clipboard"
        code_action['data-label-copy'] = data_button['copy']['name']
        code_action['data-label-success'] = data_button['success']['name']
        code_action.add_child(SVGSprite.render_svg(@context,
                                                   { 'id' => data_button['copy']['icon'],
                                                     'class' => 'icon icon-copy' }))
        code_action.add_child(SVGSprite.render_svg(@context,
                                                   { 'id' => data_button['success']['icon'],
                                                     'class' => 'icon icon-success' }))

        container = create_element('figure', doc)
        container.append_class('highlight code-blocks')

        code_header = create_element('figcaption', doc)
        code_header.append_class('code-header')
        code_header.add_child(code_title)
        code_header.add_child(code_action)
        container.add_child(code_header)

        code_section = create_element('div', doc)
        code_section.append_class("#{code_table['class']} rouge-block")
        line_numbers = create_pre_block(doc, code_table, 'td:nth-child(1)')
        code_content = create_pre_block(doc, code_table, 'td:nth-child(2)')
        code_content.set_attribute('data-block-copy', 'true')
        code_section.add_child(line_numbers)
        code_section.add_child(code_content)
        container.add_child(code_section)

        node.inner_html = container
      end
      doc
    end

    # Helper to create a pre block with code from specific query
    def create_pre_block(input, table, query)
      pre_block = create_element('pre', input)
      table.at_css(query).attributes.each { |k, v| pre_block[k] = v.value }

      code_child = create_element('code', input)
      table.at_css("#{query} pre").attributes.each { |k, v| code_child[k] = v.value }
      code_child.inner_html = table.at_css("#{query} pre").inner_html

      pre_block.add_child(code_child)
      pre_block
    end

    # Highlight specific lines in code
    def parse_mark_lines(doc)
      doc.css('[data-mark-lines]').each do |node|
        if node.at_css('table td:nth-child(2) pre')
          code_inner = node.at_css('table td:nth-child(2) pre')
        elsif node.at_css('pre code:not(:has(table))')
          code_inner = node.at_css('pre code:not(:has(table))')
        else
          next
        end

        data_lang = node['class'].match(/language-(\S+)/)&.captures&.first
        mark_lines = node['data-mark-lines'].split.map(&:to_i)
        code_block = code_inner.text

        lexer = Rouge::Lexer.find_fancy(data_lang, code_block) || Rouge::Lexers::PlainText
        formatter = Rouge::Formatters::HTML.new
        formatter = Rouge::Formatters::HTMLLineHighlighter.new(
          formatter,
          highlight_line_class: 'hll',
          highlight_lines: mark_lines
        )
        code_inner.inner_html = formatter.format(lexer.lex(code_block))
      end
      doc
    end

    # Parse and update task list items with SVG icons
    def parse_task_list(doc)
      doc.css('ul.task-list li').each do |item|
        checkbox = item.at('input.task-list-item-checkbox')
        next unless checkbox

        icon_name = checkbox['checked'] ? 'circle-check' : 'circle'
        icon_class = [checkbox['class'], (checkbox['checked'] ? 'icon checked' : 'icon disabled')].compact.join(' ')
        checkbox.replace(SVGSprite.render_svg(@context, { 'id' => icon_name, 'class' => icon_class }))
      end
      doc
    end
  end
end

Liquid::Template.register_filter(Jekyll::RebaseContent)
