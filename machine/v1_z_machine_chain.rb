module DasMachineWithParent

  # родительская машина - чтобы мы могли создавать поля из машины
  # а для этого нам надо в поле при вызове иметь ввиду и родительские правила
  # но это возможно не обязательно, если... генератор кода будет отдельно
  # впрочем посмотрим - и тогда генератору кода надо сообщать список словарей знаний..
  
  # в том чтобы выставлять родительскую машину в конструкторе лежит великий смысл
  # чтобы не накидывались условия, которые уже есть в верхних машинах и которые добавляются в конструкторе
  def initialize( parent_machine=nil )
    @parent_machine = parent_machine
    super()
  end

  def parent_machine
    @parent_machine
  end
  
  def top_machine
    k = self
    while k.parent_machine
      k = k.parent_machine
    end
    k
  end
  
#  def parent_machine=(v)
#    @parent_machine=v
#  end

  # правила с учетом родительских

  # получается - никак
  # потому что если мы начинаем учитывать родительские правила,
  # то при вызове метода поля somefield.a и при наличии a в родительском контексте
  # их правила смержатся. потому что есть правило для a и в поле, и в родительском поле
  # правильный путь это видимо маршрут через default-method внутри поля
  # который скажет - ага, ничего поле не смогло сделать - пойдем к родителям..
  # тут правда тоже получается так, что особо то поле не может мержится с родительскими правилами
  # ну да и Бог с ним пока
  def conds
    my_conds = super
    res = if @parent_machine
      @parent_machine.conds_of_scope_level(:all) + my_conds.flatten
      else
        my_conds
      end
    res
  end
  
  def conds_of_scope_level(lvl)
    acc = @parent_machine ? @parent_machine.conds_of_scope_level(lvl) : []
    @context_stack.each do |line|
      if line[:conds_of_scope_level] && line[:conds_of_scope_level][lvl]
        acc.concat( line[:conds_of_scope_level][lvl] )
      end
    end
      
#    conds.flatten.each do |k|
#      if k[:scope_level] == lvl
#        acc.push(k)
#      end
#    end
    acc
  end

  def codes
    my = super
    total = if parent_machine
        parent_machine.codes.merge( my ) # тут родина конфликтов имен..
      else
        my
      end
    total
  end
  
  def add_cond( cond, target, options={} ) 
    k,idx = super
    if k 
      if options[:scope_level]
        k[:scope_level] = options[:scope_level]
      elsif @scope_level_stack && @scope_level_stack.last
        k[:scope_level] = @scope_level_stack.last
      end
      if k[:scope_level]
        @context_stack[ idx ][:conds_of_scope_level] ||= {}
        @context_stack[ idx ][:conds_of_scope_level][ k[:scope_level] ] ||= []
        @context_stack[ idx ][:conds_of_scope_level][ k[:scope_level] ].push( k )
      end
    end
    k
  end
  
  # scope_level помогает нам понимать, какие правила тащить в глубины, а какие нет
  # т.о. если мы хотим явно сказать что надо тащить - это надо явно сказать таки через следующие методы
  def push_scope_level( v )
    @scope_level_stack ||= []
    @scope_level_stack.push(v)
  end
  
  def pop_scope_level
    @scope_level_stack.pop
  end

end

CombiningMachine.  prepend DasMachineWithParent
