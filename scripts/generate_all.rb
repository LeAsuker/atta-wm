#!/usr/bin/env ruby
# frozen_string_literal: true

require 'fileutils'
require 'pathname'

require_relative 'render_colors'
require_relative 'render_keybinds'

class ConfigSync
  CONFIG_TARGET_DIR = Pathname(File.expand_path('~/.config/atta-wm')).freeze
  AUTOSTART_TARGET_PATH = Pathname(File.expand_path('~/.config/herbstluftwm/autostart')).freeze
  FILES_TO_COPY = %w[
    alacritty.toml
    config.ini
    config.rasi
    atta-manual.txt
  ].freeze

  def initialize(project_root)
    @project_root = Pathname(project_root)
    @config_dir = @project_root.join('configs')
  end

  def sync
    ColorRenderer.new(@project_root).render_all
    KeybindingRenderer.new(@project_root).render

    sync_configs
    sync_autostart
  end

  private

  def sync_configs
    CONFIG_TARGET_DIR.mkpath
    FILES_TO_COPY.each do |filename|
      FileUtils.cp(@config_dir.join(filename), CONFIG_TARGET_DIR.join(filename))
    end
  end

  def sync_autostart
    AUTOSTART_TARGET_PATH.dirname.mkpath
    FileUtils.cp(@config_dir.join('autostart'), AUTOSTART_TARGET_PATH)
  end
end

if $PROGRAM_NAME == __FILE__
  ConfigSync.new(Pathname(__dir__).parent).sync
end