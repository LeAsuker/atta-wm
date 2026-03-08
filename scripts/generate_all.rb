#!/usr/bin/env ruby
# frozen_string_literal: true

require 'fileutils'
require 'pathname'

require_relative 'render_colors'
require_relative 'render_keybinds'

class ConfigSync
  AUTOSTART_TARGET_PATH = Pathname(File.expand_path('~/.config/herbstluftwm/autostart')).freeze

  def initialize(project_root, colors_yaml = nil)
    @project_root = Pathname(project_root)
    @config_dir = @project_root.join('configs')
    @colors_yaml = colors_yaml
  end

  def sync
    ColorRenderer.new(@project_root, @colors_yaml).render_all
    KeybindingRenderer.new(@project_root).render

    sync_autostart
  end

  private

  def sync_autostart
    AUTOSTART_TARGET_PATH.dirname.mkpath
    if AUTOSTART_TARGET_PATH.directory?
      raise "Expected #{AUTOSTART_TARGET_PATH} to be a file, but it is a directory"
    end

    FileUtils.cp(@config_dir.join('autostart'), AUTOSTART_TARGET_PATH)
  end
end

if $PROGRAM_NAME == __FILE__
  colors_yaml = ARGV[0]
  ConfigSync.new(Pathname(__dir__).parent, colors_yaml).sync
end