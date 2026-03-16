#!/usr/bin/env ruby
# frozen_string_literal: true

require 'fileutils'
require 'pathname'

require_relative 'render_colors'
require_relative 'render_keybinds'

class ConfigSync
  AUTOSTART_TARGET_PATH = Pathname(File.expand_path('~/.config/herbstluftwm/autostart')).freeze
  KITTY_TARGET_PATH = Pathname(File.expand_path('~/.config/kitty/kitty.conf')).freeze
  POLYBAR_TARGET_PATH = Pathname(File.expand_path('~/.config/polybar/config.ini')).freeze
  ROFI_TARGET_PATH = Pathname(File.expand_path('~/.config/rofi/config.rasi')).freeze
  DUNST_TARGET_PATH = Pathname(File.expand_path('~/.config/dunst/dunstrc')).freeze
  NVIM_INIT_TARGET_PATH = Pathname(File.expand_path('~/.config/nvim/init.vim')).freeze
  VIFM_TARGET_ROOTS = [
    Pathname(File.expand_path('~/.vifm')),
    Pathname(File.expand_path('~/.config/vifm'))
  ].freeze
  VIFMRC_TARGET_PATHS = VIFM_TARGET_ROOTS.map { |root| root.join('vifmrc') }.freeze
  VIFM_COLOR_TARGET_PATHS = VIFM_TARGET_ROOTS.map { |root| root.join('colors/atta-wm.vifm') }.freeze

  def initialize(project_root, colors_yaml = nil)
    @project_root = Pathname(project_root)
    @config_dir = @project_root.join('configs')
    @wm_config_dir = @config_dir.join('wm-configs')
    @tool_config_dir = @config_dir.join('tool-configs')
    @colors_yaml = colors_yaml
  end

  def sync
    ColorRenderer.new(@project_root, @colors_yaml).render_all
    KeybindingRenderer.new(@project_root).render

    sync_autostart
    sync_kitty
    sync_polybar
    sync_rofi
    sync_dunst
    sync_nvim_config
    sync_vifmrc
    sync_vifm_colors
  end

  private

  def sync_autostart
    AUTOSTART_TARGET_PATH.dirname.mkpath
    if AUTOSTART_TARGET_PATH.directory?
      raise "Expected #{AUTOSTART_TARGET_PATH} to be a file, but it is a directory"
    end

    FileUtils.cp(@wm_config_dir.join('autostart'), AUTOSTART_TARGET_PATH)
  end

  def sync_kitty
    KITTY_TARGET_PATH.dirname.mkpath
    if KITTY_TARGET_PATH.directory?
      raise "Expected #{KITTY_TARGET_PATH} to be a file, but it is a directory"
    end

    FileUtils.cp(@wm_config_dir.join('kitty.conf'), KITTY_TARGET_PATH)
  end

  def sync_polybar
    POLYBAR_TARGET_PATH.dirname.mkpath
    if POLYBAR_TARGET_PATH.directory?
      raise "Expected #{POLYBAR_TARGET_PATH} to be a file, but it is a directory"
    end

    FileUtils.cp(@wm_config_dir.join('config.ini'), POLYBAR_TARGET_PATH)
  end

  def sync_rofi
    ROFI_TARGET_PATH.dirname.mkpath
    if ROFI_TARGET_PATH.directory?
      raise "Expected #{ROFI_TARGET_PATH} to be a file, but it is a directory"
    end

    FileUtils.cp(@wm_config_dir.join('config.rasi'), ROFI_TARGET_PATH)
  end

  def sync_dunst
    DUNST_TARGET_PATH.dirname.mkpath
    if DUNST_TARGET_PATH.directory?
      raise "Expected #{DUNST_TARGET_PATH} to be a file, but it is a directory"
    end

    FileUtils.cp(@wm_config_dir.join('dunstrc'), DUNST_TARGET_PATH)
  end

  def sync_nvim_config
    NVIM_INIT_TARGET_PATH.dirname.mkpath
    if NVIM_INIT_TARGET_PATH.directory?
      raise "Expected #{NVIM_INIT_TARGET_PATH} to be a file, but it is a directory"
    end

    FileUtils.cp(@tool_config_dir.join('init.vim'), NVIM_INIT_TARGET_PATH)
  end

  def sync_vifmrc
    VIFMRC_TARGET_PATHS.each do |target_path|
      target_path.dirname.mkpath
      if target_path.directory?
        raise "Expected #{target_path} to be a file, but it is a directory"
      end

      FileUtils.cp(@tool_config_dir.join('vifmrc'), target_path)
    end
  end

  def sync_vifm_colors
    source = @tool_config_dir.join('colors/atta-wm.vifm')

    VIFM_COLOR_TARGET_PATHS.each do |target_path|
      target_path.dirname.mkpath
      if target_path.directory?
        raise "Expected #{target_path} to be a file, but it is a directory"
      end

      FileUtils.cp(source, target_path)
    end
  end
end

if $PROGRAM_NAME == __FILE__
  colors_yaml = ARGV[0]
  ConfigSync.new(Pathname(__dir__).parent, colors_yaml).sync
end