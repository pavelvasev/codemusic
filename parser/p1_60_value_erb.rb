require "erb"

class ERBContext
  
  def initialize( machine,ctx )
    @ctx = ctx
    @machine = machine
  end

  def get_binding
    binding
  end
  
  def ctx
    #STDERR.puts "ctx requested! ctx=#{@ctx}"
    @ctx
  end

  def tdata
    ctx[:tree_input] # вроде так?
  end
  
  def obj
    ctx[:request]
  end
  
  def input
    ctx.input
  end

# нафига, она в контексте есть  
#  def machine
#    @machine
#  end

  def method_missing(m, *args, &block)
    if block_given?
      @machine.compute( {:tag => m.to_sym},block,"erb-method-missing" )
    else
      @machine.compute( {:tag => m.to_sym},args,"erb-method-missing-2" )
    end
  end

  def self.const_missing(m)
    @@machine.compute( {:tag => m.to_sym},[],"erb-const-missing" )
  end
  
  def self.set_machine(ma)
    @@machine = ma
  end
  
  # я бы с радостью рендерил erb в контексте парсера - это роднило бы его с руби-методами..
  # но есть одна проблема - это вот method_missing-и, которые бы мне не хотелось бы видеть в парсере
  # во избежание ошибок работы с ним..
  # другой вариант - создать еще контекст для руби-методов и там их выполнять
  # но тогда - надо иметь общий контекст, чтобы они там работали..
  # а мне ведь надо уметь двигать ctx, и input-ы..
  # впрочем, его можно сделать равным machine.ctx, а input - machine.ctx.input..

end


module DasParseErb

  def generate_lambdum( name_part, cond_attrs, params, desired_code_id, value )
    if name_part =~ /^(.+)\.erb$/
      name_part = $1
    else
      return super
    end
    
    parser = self

    lambdum = lambda { |ctx|
      #erb = ERB.new( value, trim_mode: "<>" )
      erb = ERB.new( value,  0, "<>") # можно % добавить но я не вижу в нем смысла - только засоряет эфир плюс может вдруг безопасность нарушит
      erb.filename = "[pismo node] ### #{ctx.obj[:name]}"
      #STDERR.puts "makinng new context, passing machine: #{ctx.machine}"
      kk = ERBContext.new( ctx.machine, ctx )
      ERBContext.set_machine ctx.machine # вот
      r = erb.result( kk.get_binding )
      @machine.log "erb achieved result. passing it to next lambdum, name_part = #{name_part}"
      next_lambdum,next_name = parser.generate_lambdum( name_part, cond_attrs , params, desired_code_id, r )
      
      next_lambdum.call( ctx )
    }
    
    return super( name_part, cond_attrs, params, desired_code_id, lambdum ) # протокол такой
  end
  
  
end

LetterParser.prepend DasParseErb