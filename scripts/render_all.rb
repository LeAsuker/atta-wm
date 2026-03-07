#!/usr/bin/env ruby
# frozen_string_literal: true

require 'fileutils'
require 'pathname'

require_relative 'render_colors'
require_relative 'render_keybinds'

class ConfigSync
  TARGET_DIR = Pathname(File.expand_path('~/.config/atta-wm')).freeze
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

    TARGET_DIR.mkpath
    FILES_TO_COPY.each do |filename|
      FileUtils.cp(@config_dir.join(filename), TARGET_DIR.join(filename))
    end
  end
end

if $PROGRAM_NAME == __FILE__
  ConfigSync.new(Pathname(__dir__).parent).sync
end