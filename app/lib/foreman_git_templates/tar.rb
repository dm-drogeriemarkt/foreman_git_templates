# frozen_string_literal: true

require 'zlib'
require 'rubygems/package'

module ForemanGitTemplates
  module Tar
    def tar(filepath)
      Zlib::GzipWriter.open(filepath) do |gz|
        Gem::Package::TarWriter.new(gz) do |tar|
          yield tar if block_given?
        end
      end
    end

    def untar(filepath)
      Zlib::GzipReader.open(filepath) do |gz|
        Gem::Package::TarReader.new(gz) do |tar|
          yield tar if block_given?
        end
      end
    end

    module_function :tar, :untar
  end
end
