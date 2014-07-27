
class Rule
  def initialize(str)
    @body = str
  end

  def selectors
    @body.match(/[^{]*/).to_s.split(/,/).map{|s| s.strip}.select{|s| !s.empty? }
  end

  def props
    begin
    p = @body.match(/\{([^}]*)/)[1].split(';').select{|s| !s.strip.empty? }
    p.map{|s| "{ " + s.strip + " }"}
    rescue
      []
    end
  end

  def body
    @body
  end

end


in_file, out_file = ARGV

#file = File.open(in_file, "r")
#rules = file.read.split('}')

text = ""
file = File.open(in_file)
file.each{ |line| text += line }
text = text.gsub( /[\n\r\t]/m, " " )
text = text.gsub( / +/m, " " )
text = text.gsub( /\/\*[^*]*\*\//m, " " )
rules = text.split('}')

rules = rules.map{|r| Rule.new(r) }

hash = {}

##BUILD 
rules.each do |r|
  r.props.each do |p|
    
    #add all the keys
    if !( hash.has_key? p) then
      hash[p] = []
    end

    #add the selector
    r.selectors.each do |s|
      hash[p].push s
    end

  end
end

##PRINT
output = ""
hash.keys.sort.each do |key|
  output += "\n"
  output += hash[key].join(",\n") + "\n"
  output += key + "\n"
end

puts output

out_file = File.new(out_file, "w")
out_file.write(output)
out_file.close


