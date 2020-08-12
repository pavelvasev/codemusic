module DasOne

  def initialize
    @codes = {}
    super
  end
  
  # сигнатура cod: lambda { |ctx| ... }
  def add_code( id, cod )
    @codes[ id.to_sym ] =  cod
    #lambda{ |mmm| cod.call }
  end
  
end

module DasTwo
  def initialize
    super
  end

  # idea? а пусть cond объектом будет?
  def add_cond( cond, target, options = {} )
    cond_id = cond.is_a?(Array) ? cond[0] : cond
    cond_flags = cond.is_a?(Array) ? cond[1..-1] : []
    # target = target.to_sym if target.is_a?(String) ладно уж
    target = { :tag => target } if target.is_a?(Symbol)
    cond_record = { 
      :tag => cond_id, 
      :flags => cond_flags, 
      :target => target, 
      :priority => (options[:priority]||0)
    }
    cond_record[:prepend] = true if options[:prepend]
    
    ctx_index = options[:ctx_index].nil? ? -1 : options[:ctx_index]
    #@context_stack[ ctx_index ][:conds].push( cond_record )
    # решено хранить наши добавки в контекстах!
    log "add_cond: used ctx index: #{ctx_index}"
    log "add_cond: obj of that index is: #{ @context_stack[ ctx_index ].obj }"
    
    # treb:doubleconds
    existing = conds.flatten.detect{ |c| c[:tag] == cond_record[:tag] && c[:flags] == cond_record[:flags] && c[:target].eql?(cond_record[:target]) }
    if existing 
      log "cond duplicate found, skipping"
      return
    end
    # не добавляем дубликаты.. правда тут могут быть разные приоритеты, и м.б. если мы меняем
    # приоритет, то все-таки надо тогда добавлять..
    
    #conds[ ctx_index ].push( cond_record )
    @context_stack[ ctx_index ][ :conds ].push( cond_record )
    [cond_record, ctx_index]
  end
  
  def prepend( cond, target, options={} )
    options[:prepend] = true # mb bug - запись в выходной объект
    add_cond( cond,target,options )
  end
  
  def append( cond, target, options={} )
    add_cond( cond,target,options )
  end
  
  def conds
    @context_stack.map{ |ctx| ctx[:conds] }
  end
  
  def codes
    @codes
  end

end

module DasThree

  def compute_in_context( request )
    request = { :tag => request } if request.is_a?(Symbol)
    
    # ну тут мы делаем всякий отлуп всяким глупостям.. которые на вход идут.. не знаю, может это раньше надо делать..
    if !request.is_a?(Hash)
      log "request is not a hash - returning it as is"
      ctx.r = request # маленький бардак тут у нас - мы и в контекст должны записать, и вернуть как есть
      # todo наверное убрать надо эти возвраты в вовзращаемом значении? (но проверить все сигнатуры как используются)
      return request
    end
  
    #puts "compute: request=#{request.inspect}"
    matching = []
    #conds =
    conds.flatten.each { |cond|
      next if (cond[:target][:tag] == request[:tag]) #  защита от рекурсии 
      
      id_ok = (request[:tag] == cond[:tag] || cond[:tag].nil?) # treb:norecursion
      
      flags_ok = true
      cond[:flags].each { |flag| flags_ok = false if !request.has_key?(flag) }
      if id_ok && flags_ok
        matching.push cond
      end
    }
    # matching.uniq! 
    # uniq! это хак и треш - но именно так мы покамест убираем дубликаты.. todo подумать, может их просто не добавлять?
    # т.е. отсекать на этапе add_cond.. так в лакте сделано.. и это быстрее..
    # убрал, ибо это типа дорого жеж..
    matching.sort!{ |x,y| y[:priority] <=> x[:priority] }
    prepends = []
    appends = []
    matching.each { |cond| (cond[:prepend] ? prepends : appends).push(cond) }
    #  prepends.sort!
    
    # собственно, имеем prepends, appends, и еще ownvalue посередине
    # и самое интересное теперь - как результаты совмещать
    

    result = []
    ctx[:result] ||= [] # ну пущай тудыкось пишут
    ctx[:request] ||= request # эти ||= это особенные - они не затирают контекст таким образом..
    ctx[:obj] ||= request
    # т.е. args это у меня уже на самом деле - контекст целый..
    
    #log "chain: #{prepends.map{|c| c[:target] }.inspect} #{@codes[ request[:tag] ] ? 'OWNCODE' : ''} #{appends.map{|c| c[:target]}.inspect}"
    def c2s(cond) # condition to string
      c = cond[:target]
      k = c.is_a?(Hash) && c.keys.length == 1 && c[:tag] ? c[:tag].to_s : c.inspect
      "#{k}#p=#{cond[:priority]}"
    end
    log "chain: #{prepends.map{|c| c2s(c) }} #{codes[ request[:tag] ] ? 'OWNCODE' : '~'} #{appends.map{|c| c2s(c) }}"
    
    chain = prepends.concat( [{:owncode => request[:tag]}] ).concat( appends )
    return compute_chain( chain, request )
  end
  
  def compute_chain( arr,request )
    result = []
    k = self
    arr.each{ |cond|
      if cond[:owncode]
        if cod=codes[ cond[:owncode] ]
          #k.instance_exec{ cod.call }
          #k.instance_eval( &cod )
          log "owncode (#{request[:tag]})" do
            cod.call( ctx )
          end
        end
      else
        compute_in_context( cond[:target] )
      end
      if ctx[:stop]
        log "compute_chain: STOP FLAG detected [#{ctx[:stop]}]. Stopping chain. Cond where stopped: #{cond}"
        #log "btw res=#{ctx[:result]}"
        return ctx[:result] 
      end
      if ctx[:stop2] || ctx[:stop1]
        log "compute_chain: STOP12 FLAG detected [#{ctx[:stop2] || ctx[:stop1]}]. Stopping chain. Cond where stopped: #{cond}"
        #log "btw res=#{ctx[:result]}"
        if ctx[:stop1]
          
          ctx[:stop1] = nil
        elsif ctx[:stop2]
          ctx[:stop1] = ctx[:stop2]
          ctx[:stop2] = nil
        end
        #ctx[:stop1] = ctx[:stop1]-1
        #ctx[:stop1] = nil if ctx[:stop1] == 0
        return ctx[:result]
      end
    }
    ctx[:result]
  end
end


CombiningMachine.  prepend DasOne
CombiningMachine.  prepend DasTwo
CombiningMachine.  prepend DasThree
