require_relative "./lib/xml_loader"

# автоматически понимаешь преобразователь в чиселки пусть будет
# но это похоже только для аттрибутов
# todo вытащить все из xml_loader, надо тут свое иметь все
#NUMS
module XmlNums
  def parsetext(t)
    #STDERR.puts "parsetext: t=#{t}"
    if t =~ /\A(0|[1-9][0-9]*)\z/
      return t.to_i
    end
    if t =~ /\A(([1-9]*)|(([1-9]*)\.([0-9]*)))\z/
      return t.to_f
    end
    # вообще можно это делать для всех чисел, а не только для 1?
    super
  end

end
Nokogiri::XML::Node.prepend XmlNums

module DasParseXml

  def generate_lambdum( name_part, rmethod, params, desired_code_id, value )

    if name_part =~ /^(.+)\.xml$/
      name_part = $1
    end
    return [value, name_part] if value.is_a?(Proc) # протокол - бежать куда подальше ежели оно так
    
    if value !~ /</
      # идите лесом, это текст
      return generate_lambdum( name_part + ".txt", rmethod, params, desired_code_id, value )
    end
    
    #@machine.log "xml value before parse=#{value.inspect}"
    
    value = XMLRules.string2hash( value )
      
    # ну вот.. теперьу нас тут хеш наш.. правильный, с tag и items..
    #@machine.log "xml value=#{value.inspect}"
    
    # еще надо добавить ему признаков всяких..
    value[:root] = true #name? - да, имя надо, иначе оно никак и не передается..
    value[:name] = name_part
    # value[:names_stack] = [name_part] todo разобраться, чето стек имен не формируется,
    # хотя мне и все-равно

    lambdum = lambda { |ctx|
      node_with_top_attrs = transfer_attrs_to_top_node( ctx.obj, value.dup )
      # главное не забыть передать результат, ctx.r =...
      #ctx.rappend = 
      r=ctx.machine.compute( node_with_top_attrs, ctx[:input],"xml-lambda" ) 
      ctx.send( rmethod || "r=", r )
      
      # in_context ?? и будет ли трансфер аттрибутов? так то надо..
      # ну или можем ли мы как-то на контекст влиять? там каких-то знаний в него напихать?
      # ех.. не знаю.. разберемся..
    }
    
    return [lambdum, name_part]
  end
  
  
  ####
  def transfer_attrs_to_top_node( source, target )
    DasParseXml.transfer_attrs_to_top_node( source, target )
  end

  def self.transfer_attrs_to_top_node( source, target )

      source.keys.each do |k|
        if k == :name
          target[:names_stack] ||= []
          target[:names_stack] = target[:names_stack].concat( source[:names_stack] || []).concat( [source[:name]] )
        end
        next if [:tag,:items,:attr_names,:name,:ordinal,:getcol_invokation].include?(k) # name не стал пропускать..
        target[k] = source[k]
      end
      target
  end
  

end

LetterParser.prepend DasParseXml