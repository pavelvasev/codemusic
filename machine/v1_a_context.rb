module MachineContextInputMethods

  def initialize( machine )
    self[:machine] = machine
    self[:conds] = []
  end

  def input
    # self[:input] = eval_input( self[:input] ) || []
    # feature:nodup - теперь надо в отдельный ключ сохранять, ибо иначе постоянное дублирование - плохо
    # однако мы теперь [:input] оставляем нетронутым - тоже нюанс..
    # self[:input_processed] ||= eval_input( self[:input] ) || []
    # чето меня смущает это - вдруг потом будут этим ctx[:input] пользоваться и пойдет двойной рассчет
    if !self[:input_processed_flag]
      self[:input] = eval_input( self[:input] ) || []
      self[:input_processed_flag]=1
    end
    self[:input]
  end

  def eval_input(rec)
    if rec.is_a?(Proc)
      rec.call
    else
      if rec.respond_to?(:dup) && !rec.nil? # feature:nodup
        rec.dup
      else
        rec
      end
    end
  end
  # feature:nodup это фишка если input указывает на корневые данные - то их надо продублировать, ибо потом иначе rappend их портит
  
  def r
    self[:result]
  end
  
  def r=(value)
    self[:result] = value
  end
  
  def stop=(value)
    self[:stop] = value
  end
  
  def stop2=(value)
    self[:stop2] = value
  end
  
  def rappend=(value)
    if !self[:result].is_a?(Array) 
      self[:result] = [ self[:result] ]
    end
    self[:result].push( value )
  end
  # idea rappend, rprepend?
  
  # короткие штуки
  def machine
    self[:machine]
  end
  
  def obj
    self[:request]
  end
  
end

module DasMachineContext

  def initialize()
    @context_stack = [ MachineContext.new(self) ] # 1 штучка пусть там живет как минимум
    super
  end

  def compute( request, data, comment )
    return compute_in_context( request ) if data.is_a?(MachineContext)
    #raise "uuu" if data.is_a?(Hash)

    ctx = MachineContext.new( self )
    ctx[:input] = data
    ctx[:parent] = @context_stack.last
    @context_stack.push ctx
    
    r = compute_in_context( request )
    r = after_compute( r ) # эх, вот явное.. но нам это надо, чтобы сюда дефолт-метод воткнуть
    
    @context_stack.pop
    r
  end
  
  def after_compute(r)
    r
  end
  
  def ctx
    @context_stack.last
  end
  
  # фича state, пока сюда запихаем..
  # смысл в том, что нам надо иметь некие знания..
  def state
    @state ||= {}
  end
  # но вообще надо уже уметь делать лукап в контекстах..
  
end

CombiningMachine.  prepend DasMachineContext
MachineContext.prepend MachineContextInputMethods