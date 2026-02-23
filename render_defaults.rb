#!/usr/bin/env ruby
# frozen_string_literal: true

# render_defaults.rb — Developer helper
# Reads Configs/colors.yml and renders every Configs/*.template into its
# corresponding pre-rendered default (e.g. autostart.template → autostart).
#
# Run this before committing whenever colors.yml or any .template changes:
#   ruby render_defaults.rb

require 'yaml'

REPO_ROOT   = __dir__
CONFIGS_DIR = File.join(REPO_ROOT, 'Configs')
COLORS_FILE = File.join(CONFIGS_DIR, 'colors.yml')

# ── helpers (duplicated from apply_colors.rb to stay self-contained) ─────────

def hex_to_rgba(hex)
  hex = hex.strip.delete_prefix('#')
  r = hex[0..1].to_i(16)
  g = hex[2..3].to_i(16)
  b = hex[4..5].to_i(16)
  "rgba ( #{r}, #{g}, #{b}, 100 % )"
end

def render(template, colors)
  result = template.dup

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

unless File.exist?(COLORS_FILE)
  warn "Error: #{COLORS_FILE} not found"
  exit 1
end

colors = YAML.safe_load_file(COLORS_FILE)

templates = Dir.glob(File.join(CONFIGS_DIR, '**', '*.template'))

if templates.empty?
  warn 'No .template files found in Configs/.'
  exit 0
end

puts "Rendering defaults from #{COLORS_FILE}..."
puts

templates.each do |tpl_path|
  out_path = tpl_path.sub(/\.template\z/, '')
  content  = File.read(tpl_path)
  rendered = render(content, colors)
  File.write(out_path, rendered)

  if File.basename(out_path) == 'autostart'
    File.chmod(0o755, out_path)
  end

  rel = out_path.sub("#{REPO_ROOT}/", '')
  puts "  ✔  #{rel}"
end

puts
puts 'Done. Pre-rendered defaults are up to date.'
