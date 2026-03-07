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

  def initialize(config_dir)
    @config_dir = Pathname(config_dir)
  end

  def sync
    ColorRenderer.new(@config_dir).render_all
    KeybindingRenderer.new(@config_dir).render

    TARGET_DIR.mkpath
    FILES_TO_COPY.each do |filename|
      FileUtils.cp(@config_dir.join(filename), TARGET_DIR.join(filename))
    end
  end
end

if $PROGRAM_NAME == __FILE__
  ConfigSync.new(__dir__).sync
end