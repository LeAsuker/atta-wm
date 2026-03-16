#!/usr/bin/env ruby
# frozen_string_literal: true

require 'erb'
require 'fileutils'
require 'yaml'
require 'pathname'

class ColorRenderer
  DEFAULT_THEME_NAME = 'custom'
  DEFAULT_WALLPAPER = 'wallhaven-thinkpad1.jpg'

  TEMPLATE_MAP = {
    'kitty.conf.erb' => 'wm-configs/kitty.conf',
    'autostart.erb' => 'wm-configs/autostart',
    'config.ini.erb' => 'wm-configs/config.ini',
    'config.rasi.erb' => 'wm-configs/config.rasi',
    'dunstrc.erb' => 'wm-configs/dunstrc',
    'vimrc.erb' => 'tool-configs/vimrc',
    'vifmrc.erb' => 'tool-configs/vifmrc',
    'atta-wm.vifm.erb' => 'tool-configs/colors/atta-wm.vifm'
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

    @active_theme_name = detect_active_theme_name(colors_path)

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
    validate_hex(section, name, value)
  end

  def vifm_hex(name)
    vifm_theme = themes['vifm']
    if vifm_theme && vifm_theme.key?(name.to_s)
      return validate_hex(:vifm, name, vifm_theme.fetch(name.to_s))
    end

    section, key = vifm_fallback.fetch(name)
    theme_hex(section, key)
  end

  def vifm_colorscheme_name
    'atta-wm'
  end

  def validate_hex(section, name, value)
    unless value.match?(/^#[0-9A-Fa-f]{6}$/)
      raise ArgumentError, "Invalid hex color for #{section}.#{name}: #{value}"
    end

    value.upcase
  end

  def vifm_fallback
    {
      foreground: [:kitty, :foreground],
      background: [:kitty, :background],
      inactive_background: [:rofi, :light_background],
      accent: [:rofi, :accent],
      current_line: [:rofi, :light_background],
      directory: [:hlwm, :title_color],
      link: [:kitty, :cyan],
      executable: [:kitty, :green],
      broken_link: [:dunst, :critical_bg],
      border: [:hlwm, :border_highlight],
      error: [:dunst, :critical_bg],
      line_nr: [:polybar, :muted]
    }.freeze
  end

  def theme_rgba(section, name, alpha = 100)
    red, green, blue = theme_hex(section, name).delete_prefix('#').scan(/../).map { |channel| channel.to_i(16) }
    "rgba ( #{red}, #{green}, #{blue}, #{alpha} % )"
  end

  def theme_font(section, name = :font, default = 'UbuntuMono')
    section_map = themes[section.to_s]
    value = section_map && section_map[name.to_s]
    return value if value.is_a?(String) && !value.strip.empty?

    warn "[render_colors] Missing #{section}.#{name}; default font loaded: #{default}"
    default
  end

  def active_theme_name
    @active_theme_name
  end

  def selected_theme_wallpaper
    wallpaper = themes['wallpaper']
    return wallpaper if wallpaper.is_a?(String) && !wallpaper.strip.empty?

    DEFAULT_WALLPAPER
  end

  def detect_active_theme_name(colors_path)
    themes_dir = @project_root.join('themes')
    if themes_dir.to_s == colors_path.dirname.to_s
      return colors_path.basename('.yaml').to_s
    end

    loaded_yaml = YAML.safe_load(colors_path.read, permitted_classes: [], aliases: false)
    themes_dir.glob('*.yaml').sort.each do |theme_file|
      candidate_yaml = YAML.safe_load(theme_file.read, permitted_classes: [], aliases: false)
      return theme_file.basename('.yaml').to_s if candidate_yaml == loaded_yaml
    end

    DEFAULT_THEME_NAME
  end
end

if $PROGRAM_NAME == __FILE__
  colors_yaml = ARGV[0]
  ColorRenderer.new(Pathname(__dir__).parent, colors_yaml).render_all
end
