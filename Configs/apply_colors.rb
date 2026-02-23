#!/usr/bin/env ruby
# frozen_string_literal: true

# apply_colors.rb — Reads a YAML color palette and renders *.template files
# into final config files by substituting {{key}} and {{rgba:key}} placeholders.
#
# Usage:
#   ruby apply_colors.rb <colors.yml> <config_dir>
#
# Example (installer):
#   ruby apply_colors.rb ~/.config/mikuflavor/colors.yml ~/.config/mikuflavor
#
# The script also handles the herbstluftwm autostart which lives in a
# separate directory. If a config_dir contains autostart.template, it is
# rendered in place.

require 'yaml'

# ── helpers ──────────────────────────────────────────────────────────────────

# Convert a hex color like "#07DAE2" to Rofi rgba format:
#   "rgba ( 7, 218, 226, 100 % )"
def hex_to_rgba(hex)
  hex = hex.strip.delete_prefix('#')
  r = hex[0..1].to_i(16)
  g = hex[2..3].to_i(16)
  b = hex[4..5].to_i(16)
  "rgba ( #{r}, #{g}, #{b}, 100 % )"
end

# Replace all {{key}} and {{rgba:key}} placeholders in a string.
def render(template, colors)
  result = template.dup

  # {{rgba:key}} → rgba( r, g, b, 100 % )
  result.gsub!(/\{\{rgba:(\w+)\}\}/) do
    key = Regexp.last_match(1)
    value = colors[key]
    if value
      hex_to_rgba(value)
    else
      warn "  ⚠  unknown rgba key: #{key}"
      "{{rgba:#{key}}}"
    end
  end

  # {{key}} → raw value (hex string)
  result.gsub!(/\{\{(\w+)\}\}/) do
    key = Regexp.last_match(1)
    value = colors[key]
    if value
      value.to_s
    else
      warn "  ⚠  unknown key: #{key}"
      "{{#{key}}}"
    end
  end

  result
end

# ── main ─────────────────────────────────────────────────────────────────────

if ARGV.length < 2
  warn "Usage: ruby #{$PROGRAM_NAME} <colors.yml> <config_dir>"
  exit 1
end

colors_path = ARGV[0]
config_dir  = ARGV[1]

unless File.exist?(colors_path)
  warn "Error: #{colors_path} not found"
  exit 1
end

unless Dir.exist?(config_dir)
  warn "Error: #{config_dir} is not a directory"
  exit 1
end

colors = YAML.safe_load_file(colors_path)

templates = Dir.glob(File.join(config_dir, '**', '*.template'))

if templates.empty?
  warn 'No .template files found.'
  exit 0
end

templates.each do |tpl_path|
  out_path = tpl_path.sub(/\.template\z/, '')
  content  = File.read(tpl_path)
  rendered = render(content, colors)
  File.write(out_path, rendered)

  # Preserve executable bit (important for autostart)
  if File.basename(out_path) == 'autostart'
    File.chmod(0o755, out_path)
  end

  puts "  ✔  #{out_path}"
end

puts 'Done.'
