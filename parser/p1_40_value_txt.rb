module DasParseTxt

  def initialize(*args)
    super
    
    @machine.add_code :pass_value, lambda { |ctx|
      ctx.r = ctx.obj.has_key?(:value) ? ctx.obj[:value] : ctx.input
    }
  end

  def generate_lambdum( name_part, rmethod, params, desired_code_id, value )
    if name_part =~ /^(.+)\.txt$/
      name_part = $1
    else
      return super
    end
    return [value, name_part] if value.is_a?(Proc) # протокол - бежать куда подальше ежели оно так

    lambdum = lambda { |ctx|
      # вот зачем я сделал эту pass_value я уже не помню.. а! чтобы root ловить! он мне нужен потом будет для compute-node! да!
      v = ctx.machine.compute( {:tag => :pass_value, :root => true, :name => name_part, :value => value },ctx[:input],"txt-lambda" )
      ctx.send( rmethod || "r=",v )
    }

    return [lambdum, name_part]
  end

end

LetterParser.prepend DasParseTxt