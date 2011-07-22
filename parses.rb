require 'open-uri'

class Parses
  BLOCK_COMMENT = /\/\*.*?\*\//m
  LINE_COMMENT =  /\/\/.*/

    attr_accessor :in_file, :out_file, :out_hash
  def initialize(args)
    @in_file, @out_file = args
  end

  def run
    self.remove_comments
    self.remove_newlines
    self.construct_hash
    self.construct_file
    self
  end

  def lines
    @lines ||= open( @in_file ).read
  end

  def remove_comments
    lines.gsub! /\/\*.*?\*\//m, ''
    lines.gsub! /\/\/[^www\.].*/, ''
    self
  end

  def remove_newlines
    lines.gsub! /;\s*$\n/, "; "
    lines.gsub! /,\s*$\n/, ", "
    lines.gsub! /\{\s*$\n/, "{ "
    lines.gsub! /^\s*\}\n/, " }"
    self
  end

  def construct_hash
    @out_hash = {}
    lines.split(/\n/).each do |line|
      /(.+)\{(.+)\}/ =~ line
      next if $1.nil?
      next if $2.nil?
      selectors, attributes = $1, $2

      attributes.split( ';' ).each do |attr|
        next if attr.strip.empty?
        @out_hash["{ #{attr.strip}; }"] ||=[]
        @out_hash["{ #{attr.strip}; }"] += selectors.split(',').map{ |s| s.strip }
      end
    end
  end

  def construct_file
    sorted_keys = @out_hash.keys.sort

    File.open(out_file, 'w+') do |writer|
      sorted_keys.each do |attr|
        selectors = @out_hash[attr]

        selectors.each do |selector|
          unless selectors.last == selector
            selector = selector + ','
          end

          writer.puts selector
        end
        writer.puts attr
        writer.puts
      end
    end

  end
end

parses = Parses.new ARGV
parses.run

__END__

