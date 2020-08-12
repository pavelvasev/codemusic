module DasParseCsv

  def generate_lambdum( name_part, rmethod, params, desired_code_id, value )
    if name_part =~ /^(.+)\.csv$/
      name_part = $1
    else
      return super
    end
    return [value, name_part] if value.is_a?(Proc) # протокол - бежать куда подальше ежели оно так
    
    value = value.split("\n").map { |line|
      line.split(/[\s,]+/).map{ |e| prepare_param_value(e) }
=begin      
       { |t|
        if t =~ /\A(0|[1-9][0-9]*)\z/
          return t.to_i
        end
        if t =~ /\A(([1-9]*)|(([1-9]*)\.([0-9]*)))\z/
          return t.to_f
        end
        t
      }
=end      
    }
    
    if params[:flatten]
      value = value.flatten
      STDERR.puts "csv data flattened: #{value.inspect}"
    end
    
    lambdum = lambda { |ctx|
      ctx.send( rmethod || "r=",value )
    }
    
    return [lambdum, name_part]
  end

end

LetterParser.prepend DasParseCsv