# вызов дефолтного метода

module DasDefaultMethod

  def after_compute( r )
    if ctx[:stop] || ctx.r_assigned?
      return r
    end
    ctx[:input] = [ ctx.obj, ctx[:input] ? ctx[:input].dup : [] ] # вот так то.. хотя может тут compute вызывать?
    compute_in_context( { :tag => :default_method } )
  end

end


CombiningMachine.  prepend DasDefaultMethod

