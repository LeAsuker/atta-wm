#!/usr/bin/env ruby
# frozen_string_literal: true

require 'pathname'
require 'shellwords'

class KeybindingRenderer
  OUTPUT_FILENAME = 'atta-manual.txt'

  def initialize(config_dir)
    @config_dir = Pathname(config_dir)
    @autostart_path = @config_dir.join('autostart')
    @output_path = @config_dir.join(OUTPUT_FILENAME)
  end

  def render
    @output_path.write(entries.join("\n") + "\n")
  end

  private

  def entries
    lines = logical_lines
    mod = extract_mod(lines)
    manual_entries = lines.filter_map { |line| parse_binding(line, mod) }
    manual_entries.concat(workspace_entries(mod)) if workspace_loop_present?(lines)
    manual_entries
  end

  def logical_lines
    combined = []
    buffer = +''

    @autostart_path.each_line do |raw_line|
      stripped = raw_line.chomp
      next if stripped.empty?

      if buffer.empty?
        buffer = stripped
      else
        buffer << ' ' << stripped.lstrip
      end

      if stripped.end_with?('\\')
        buffer = buffer.delete_suffix('\\').rstrip
        next
      end

      combined << buffer
      buffer = +''
    end

    combined << buffer unless buffer.empty?
    combined
  end

  def extract_mod(lines)
    mod_line = lines.find { |line| line.match?(/^Mod=\S+/) }
    raise 'Could not find Mod assignment in autostart' unless mod_line

    mod_line.split('#', 2).first.split('=', 2).last.strip
  end

  def parse_binding(line, mod)
    return unless line.lstrip.start_with?('hc keybind ', 'hc mousebind ')

    tokens = Shellwords.split(line)
    return if tokens.length < 4
    return unless tokens[0] == 'hc'
    return unless %w[keybind mousebind].include?(tokens[1])
    return if workspace_template_binding?(tokens[2])

    keybind = normalize_keybind(tokens[2], mod)
    function = tokens[3..].join(' ')
    "#{keybind}:#{function}"
  end

  def normalize_keybind(keybind, mod)
    keybind.gsub('$Mod', mod)
  end

  def workspace_template_binding?(keybind)
    keybind.include?('$key') || keybind.include?('${')
  end

  def workspace_loop_present?(lines)
    lines.any? { |line| line.include?('tag_keys=( {1..9} 0 )') } &&
      lines.any? { |line| line.include?('use_index "$i"') } &&
      lines.any? { |line| line.include?('move_index "$i"') }
  end

  def workspace_entries(mod)
    [
      "#{mod}-[1..9,0]:use_index",
      "#{mod}-Shift-[1..9,0]:move_index"
    ]
  end
end

if $PROGRAM_NAME == __FILE__
  KeybindingRenderer.new(__dir__).render
end