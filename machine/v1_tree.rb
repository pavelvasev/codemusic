module DasTree

  def initialize
    super
    this_machine = self
    
    # в том что срабатывать только при наличии :items лежит размышление, что иначе
    # у нас бы у кодов, не имещих items, input всегда заменялся бы на пустышку
    # что, согласитесь, не удобно.
    add_cond( [nil, :items], :tree_items_to_input, :prepend => true, :priority => 1000 )
    
    add_code( :tree_items_to_input, lambda { |ctx|
      
      orig_input = ctx[:input]
      new_input = lambda {
         #log "new_input called.. 
         m = ctx[:request][:items_machine] ||  this_machine # todo вытащить это отсыда в слои
         m.compute( ctx[:request][:items], orig_input,"tree-input" ) # я вот не понимаю.. это значит что теперь? что контекст не сменится?
      }
      
      #log "ii=#{ctx[:input]}"
      #raise "eeee" if ctx[:input].is_a?(Hash)
      ctx[:tree_input] = ctx[:input]
      ctx[:input] = new_input
    } )
    
    add_code( :tdata, lambda { |ctx|
      log "DasTree: tdata code called... ctx[:tree_input]=#{ctx[:tree_input].inspect}, ctx[:input] = #{ctx[:input].inspect}"
      #ctx.eval_input( ctx[:tree_input] )
      # удивление в том, что у нас при всех вызовах items передаются оригинальные входные данные
      # и поэтому они доступны по ctx[:input]..
      # а нафига мы тогда вообще храним ctx[:tree_input]?
      r = ctx.eval_input( ctx[:input] )
      
      if ctx.obj[:get]
        ctx.r = r[ ctx.obj[:get] ]
      else
        ctx.r = r
      end
      
      log "tdata res=#{r}"
      r
    } )

  end
end

module MachineContextTreeInput

  def tree_input
    self[:tree_input] = eval_input( self[:tree_input] ) || []
  end
  
end


CombiningMachine.prepend DasTree
MachineContext.prepend MachineContextTreeInput