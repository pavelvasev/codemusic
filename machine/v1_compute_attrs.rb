# вычисление attr встроенных в дерево

module DasAttrsPrecompute

  def initialize
    super
    
    # вычисление узла attr
    # - вернуть аттрибут value, либо вернуть тело
    # - todo value наверное можно будет интерполировать
    add_code :attr, lambda { |ctx|
      if ctx.obj[:value]
        ctx.r = [ctx.obj[:value]] # так надо, потому что там потом будут вытаскивать 0-вой элемент
        return
      end
      ctx.r = ctx.input
      #STDERR.puts "ARR 
      # а кстати вопрос..а не наоборот ли? не должен ли attr вернуть первый элемент?
      # потому что это странно так-то..
      # но оно ниже отрезается..
    }
  end

  def compute(obj,input,comment)
    return super if !obj.is_a?(Hash)
  
    normal_items = []
    new_attrs = {}
    machine = self
    
      (obj[:items] || []).each do |item|
        if item.is_a?(Hash) && item[:tag] == :attr
          #log "found attr: #{item}"

          value = machine.compute( item, input,"attr-compute-value" )
          #log "attr value computed: #{value.inspect}"
          new_attrs[ item[:name].to_sym ] = value [0]
          # хак - или что, не знаю, но получается мы берем только первый аргумент... ну или не знаю, надо смотреть будет

          # todo сделать такую фичу_ что attr вложенный в attr давал бы нам компоненту.
          #а еще
          # <visf spheres="1" spheres.nx="15" spheres.ny="22" /> ну это то норм и так сейчас будет
          # но кстати, а как тогда делать такое через attrs?
          # <attr name="spheres" value="1" nx="15" ny="22"/> ? (так то и логично..)
        else
          normal_items.push( item )
       end
     end

     if new_attrs.keys.length == 0
       return super
     end

     # наша объекта сама является аттрибутом - вернем хеш вложенных аттрибутов
     if obj[:attr]
       return new_attrs
     end

     new_attrs[:items] = normal_items
     obj = obj.dup.merge( new_attrs )
     #log "object patched with attrs. obj=#{obj.inspect}, new_attrs = #{new_attrs.inspect}"
     super( obj, input, comment )
  end
  
end

CombiningMachine.prepend DasAttrsPrecompute