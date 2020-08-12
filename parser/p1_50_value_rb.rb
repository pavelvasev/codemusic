module DasParseRuby

  def generate_lambdum( name_part, rmethod, params, desired_code_id, value )
    if name_part =~ /^(.*)\.rb$/
      name_part = $1
    else
      return super
    end
    # шобы ерб работало
    if value.is_a?(Proc)
      return [value, name_part]
    end

    lambdum = lambda { |ctx|
      obj = ctx.obj
      r = instance_eval( value, desired_code_id.to_s, 0 )
      #r = instance_eval( value )
      # второй и третий аргумент это для поиска ошибок, см https://apidock.com/ruby/BasicObject/instance_eval
      ctx.send( rmethod, r ) if rmethod
    }
    return [lambdum, name_part]
  end
  
  
end

LetterParser.prepend DasParseRuby