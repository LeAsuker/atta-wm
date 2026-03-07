#!/usr/bin/env ruby
# frozen_string_literal: true

require 'erb'
require 'yaml'
require 'pathname'

class ColorRenderer
  TEMPLATE_MAP = {
    'templates/alacritty.toml.erb' => 'alacritty.toml',
    'templates/autostart.erb' => 'autostart',
    'templates/config.ini.erb' => 'config.ini',
    'templates/config.rasi.erb' => 'config.rasi'
  }.freeze

  def initialize(config_dir)
    @config_dir = Pathname(config_dir)
    yaml = YAML.safe_load(@config_dir.join('colors.yaml').read, permitted_classes: [], aliases: false)
    @palette = yaml.fetch('palette')
  end

  def render_all
    TEMPLATE_MAP.each do |template_path, output_path|
      template = @config_dir.join(template_path)
      output = @config_dir.join(output_path)
      rendered = ERB.new(template.read, trim_mode: '-').result(binding)
      output.write(rendered)
    end
  end

  private

  attr_reader :palette

  def hex(name)
    value = palette.fetch(name.to_s)
    unless value.match?(/^#[0-9A-Fa-f]{6}$/)
      raise ArgumentError, "Invalid hex color for #{name}: #{value}"
    end

    value.upcase
  end

  def rgba(name, alpha = 100)
    red, green, blue = hex(name).delete_prefix('#').scan(/../).map { |channel| channel.to_i(16) }
    "rgba ( #{red}, #{green}, #{blue}, #{alpha} % )"
  end
end

ColorRenderer.new(__dir__).render_all
