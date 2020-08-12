require "json"

module DasParseJson

  def generate_lambdum( name_part, rmethod, params, desired_code_id, value )
    if name_part =~ /^(.+)\.json$/
      name_part = $1
    else
      return super
    end
    return [value, name_part] if value.is_a?(Proc) # протокол - бежать куда подальше ежели оно так
    
    #@machine.log "gonna json parse"
    
    value = JSON.parse(value)
    lambdum = lambda { |ctx|
      #ctx.machine.log "hello from json lambda. value=#{value}, rmethod=#{rmethod || 'r='}"
      ctx.send( rmethod || "r=", value )
    }
    
    return [lambdum, name_part]
  end

end

LetterParser.prepend DasParseJson