require 'nokogiri'

class Nokogiri::XML::Node
  TYPENAMES = {1=>'element',2=>'attribute',3=>'text',4=>'cdata',8=>'comment'}
  
  # сюда втыкать аспекты можно
  def parsetext(t)
    #STDERR.puts ">>>> bebe t=#{t}"
    t
  end
  
#  def to_hash
#    r = to_hash2
#    STDERR.puts "NOKO text was=#{text} and result is r=#{r}" if text?
#    r
#  end
  
  def to_hash
    #STDERR.puts "UUU name=#{name}"
    if text?
      #STDERR.puts "text=#{text}"
      stripped = text.strip
      return nil if stripped.length == 0
      return parsetext(stripped)
    end
    if comment?
      return nil
    end
    {:tag => name.to_sym}.tap do |h|
      h.merge! name.to_sym => 1
      h.merge! :ordinal => 1 # treb:xmlsee
      if element? && attribute_nodes.length > 0
        attrs = {}
        attribute_nodes.each do |attr| 
          #STDERR.puts "EEEE attr.name=#{attr.name}"
          attrs[ attr.name.to_sym ] = parsetext( attr.value )
        end
        h.merge! attrs
        h.merge!( {:attr_names => attrs.keys} )
      end
      if element?
        items = []
        children.each do |c|
          r = c.to_hash
          next if r.nil?
          items.push r
        end
        if items.length > 0
          h.merge! :items => items
        end
      elsif cdata?
        h[:text] = text
        h[:cdata] = 1
      end
      
    end
  end
end

class Nokogiri::XML::Document
  def to_hash; root.to_hash; end
end

module XMLRules
  
  def self.import_file( dic, file )
      doc = File.open( file ) { |f| Nokogiri::XML(f) }
      tree = doc.to_hash
      name = File.basename( file,".xml" )
      dic.eval( tree, {:ruleset_name => name} )
      # идет расчет на то что rules/rule теги будут обработаны! см rules_common/ruleset.rb
  end
  
  def self.import_string( dic, str, ruleset_name )
      doc = Nokogiri::XML(str)
      tree = doc.to_hash
      dic.eval( tree, {:ruleset_name => ruleset_name} )
      # идет расчет на то что rules/rule теги будут обработаны! см rules_common/ruleset.rb
  end
  
  def self.string2hash( str )
      doc = Nokogiri::XML(str)
#      STDERR.puts "noko.. str=#{str}, doc=#{doc.inspect}.. doc.root=#{doc.root.inspect}"
      tree = doc.to_hash
#      STDERR.puts "noko res tree=#{tree.inspect}"
      tree
  end
  
end