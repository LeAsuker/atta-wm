#!/usr/bin/env ruby
# frozen_string_literal: true

require 'erb'
require 'fileutils'
require 'yaml'
require 'pathname'

class ColorRenderer
  TEMPLATE_MAP = {
    'kitty.conf.erb' => 'wm-configs/kitty.conf',
    'autostart.erb' => 'wm-configs/autostart',
    'config.ini.erb' => 'wm-configs/config.ini',
    'config.rasi.erb' => 'wm-configs/config.rasi',
    'dunstrc.erb' => 'wm-configs/dunstrc',
    'vimrc.erb' => 'tool-configs/vimrc',
    'vifmrc.erb' => 'tool-configs/vifmrc'
  }.freeze

  def initialize(project_root, colors_yaml = nil)
    @project_root = Pathname(project_root)
    @config_dir = @project_root.join('configs')
    @template_dir = @project_root.join('templates')
    colors_path = colors_yaml ? Pathname(colors_yaml).expand_path : @config_dir.join('colors.yaml')
    raise ArgumentError, "Colors file not found: #{colors_path}" unless colors_path.exist?

    # Keep configs/colors.yaml in sync with the active theme
    default_path = @config_dir.join('colors.yaml')
    if colors_path != default_path.expand_path
      FileUtils.cp(colors_path, default_path)
    end

    yaml = YAML.safe_load(colors_path.read, permitted_classes: [], aliases: false)
    @themes = yaml
  end

  def render_all
    TEMPLATE_MAP.each do |template_name, output_path|
      template = @template_dir.join(template_name)
      output = @config_dir.join(output_path)
      output.dirname.mkpath
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
  colors_yaml = ARGV[0]
  ColorRenderer.new(Pathname(__dir__).parent, colors_yaml).render_all
end
