
puts ARGV.first
out = {}
withoutComments = File.read(ARGV.first).gsub( /(\*([^*]|[\r\n]|(\*+([^*\/]|[\r\n])))*\*+)/,'' ).gsub( /\/\/.*/, '' )
withoutComments.gsub!( /\{/, ' {')
withoutComments.gsub!( /\}\s?$/, '}__!__')
withoutComments.gsub!( /[\n|\r]/, ' ')

withoutComments = withoutComments.split('__!__')
puts withoutComments

withoutComments.each do |line|
  /(.+)\{(.+)\}/ =~ line
  next if $1.nil?
  next if $2.nil?
  selectors, attributes = $1, $2

  attributes.split( ';' ).each do |attr|
    next if attr.strip.empty?
    out["{ #{attr.strip}; }"] ||=[]
    out["{ #{attr.strip}; }"] << selectors.split(',')
  end
end

sorted_keys = out.keys.sort

File.open(ARGV.last, 'w+') do |writer|
  sorted_keys.each do |attr|
    selectors = out[attr]

    selectors.flatten!
    selectors.flatten.each do |selector|
      selector.strip!
      unless selectors.last.strip == selector
        selector = selector + ','
      end

      puts selector
      writer.puts selector
    end
    puts attr
    writer.puts attr
    puts ''
    writer.puts
  end
end

