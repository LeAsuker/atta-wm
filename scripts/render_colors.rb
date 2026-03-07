#!/usr/bin/env ruby
# frozen_string_literal: true

require 'erb'
require 'yaml'
require 'pathname'

class ColorRenderer
  TEMPLATE_MAP = {
    'alacritty.toml.erb' => 'alacritty.toml',
    'autostart.erb' => 'autostart',
    'config.ini.erb' => 'config.ini',
    'config.rasi.erb' => 'config.rasi'
  }.freeze

  def initialize(project_root)
    @project_root = Pathname(project_root)
    @config_dir = @project_root.join('configs')
    @template_dir = @project_root.join('templates')
    yaml = YAML.safe_load(@config_dir.join('colors.yaml').read, permitted_classes: [], aliases: false)
    @themes = yaml
  end

  def render_all
    TEMPLATE_MAP.each do |template_name, output_path|
      template = @template_dir.join(template_name)
      output = @config_dir.join(output_path)
      rendered = ERB.new(template.read, trim_mode: '-').result(binding)
      output.write(rendered)
    end
  end

  private

  attr_reader :themes

  def theme_hex(section, name)
    value = themes.fetch(section.to_s).fetch(name.to_s)
    unless value.match?(/^#[0-9A-Fa-f]{6}$/)
      raise ArgumentError, "Invalid hex color for #{section}.#{name}: #{value}"
    end

    value.upcase
  end

  def theme_rgba(section, name, alpha = 100)
    red, green, blue = theme_hex(section, name).delete_prefix('#').scan(/../).map { |channel| channel.to_i(16) }
    "rgba ( #{red}, #{green}, #{blue}, #{alpha} % )"
  end
end

if $PROGRAM_NAME == __FILE__
  ColorRenderer.new(Pathname(__dir__).parent).render_all
end
