# frozen_string_literal: true

require 'zlib'
require 'rubygems/package'

module ForemanGitTemplates
  class RepositoryReader
    def initialize(tempfile)
      @tempfile = tempfile
    end

    def read(filepath)
      reader.rewind
      reader.each { |e| break e.read if e.full_name.end_with?(filepath) }
    end

    private

    attr_reader :tempfile

    def reader
      @reader ||= begin
        file = File.open(tempfile, 'rb')
        gz = Zlib::GzipReader.wrap(file)
        Gem::Package::TarReader.new(gz)
      end
    end
  end
end
