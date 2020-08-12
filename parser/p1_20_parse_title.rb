# парсер заголовка

    # title это первая строчка, то что идет в ###### title
    # нам надо как минимум собрать такую информацию:
    # 1. имя кода cond
    # 2. процессоры (языки) для кода. Предлагается делать через точечку, как в рельсе. Будет типа someitem.json.erb - прикольно. Но конечно это конфликт легкий с древовидностью, ну и ладно/
    #    потому что другие то варианты какие? someitem <- json <- erb ? someitem@json@erb? не знаю. попробуем через точку
    # 3. набор ключей для условия. предлагается сделать как в css! т.е. someitem [attr1,attr2,attr3] (ну или [] в каждом - не знаю)! у них в каждом!
    #    ну хрен с ним, пусть будет в каждом..
    # 4. ну и дальше уже обычные ключики
    
    # итого шаблон: title = condname.ext1.ext2 [attr1] [attr2] alfa beta=5 gamma=6
    # быть может добавим еще указания id создаваемого кода? типа @name?
    # причем condname может быть и пустым.. ну можно договориться писать там nil тогда.. фигли

module DasParseTitle

  def initialize(*args)
    super
    @code_counter = 0
  end
  
  def generate_code_id( name_part )
    "code_#{@code_counter=@code_counter+1}_for_#{name_part}" # todo контекст файла сюда
  end
  
  def process_record( title, value )
    # вытаскиваем параметры
    title =~ /(\S+) ?(.+)?/
    name_part = $1
        
    paramspart = ($2 || "").strip
    params = {}
    cond_attrs = []
    desired_code_id = nil
    paramspart.split(/\s+/).each do |param|
      if param[0] == "["                       # аттрибут
        fail if param[-1] != "]"
        cond_attrs.push( param[1..-2].strip.to_sym )
        next
      end
      if param[0] == "@"                       # айдишнег
        desired_code_id = param[1..-1]
        next
      end
                                               # пораметер
      kv=param.split(/=/)
      params[ kv[0].to_sym ]=prepare_param_value( kv[1] || true )
    end
    
    desired_code_id ||= generate_code_id( name_part )
    
    # итого у нас есть name_part, cond_attrs, params, desired_code_id
    # красота!
    
    process_parsed_record( name_part, cond_attrs, params, desired_code_id.to_sym, value )
  end
    
  def prepare_param_value( t )
    return t if !t.is_a?(String)
    if t =~ /^(0|[1-9][0-9]*)$/
      return t.to_i
    end
    if t =~ /^(([1-9]*)|(([1-9]*)\.([0-9]*)))$/
      return t.to_f
    end
    t
  end
  
  # воот. и засим получается все у нас в эту штуку упирается, process_parsed_record
  # и видимо мы должны как-то на этот сигнал отреагировать - добавить там кодов куда надо
  # но главное, теперичмо, это понять что у нас за value, на каком языке оно написано,
  # и сообразно все это выдать. причем. у нас цепочка кодов может быть. типа .rb.erb
  # ну а если один код, что он должен выдать? в двидиум он выдавал хеш-схему, которая превращалась тупо в eval
  # ну значит, что мы тут можем так-то тоже по name_part и value выдать лямбду..
  # коюю и засунуть в add_code и затем в append (prepend)
  def process_parsed_record( name_part, cond_attrs, params, desired_code_id,value )
    @machine.log "default process_parsed_record: name_part=#{name_part.inspect}, cond_attrs=#{cond_attrs}, params=#{params}, codeid=#{desired_code_id}"
    
    rmethod = nil
    assign_mode = nil
    
    # удобство - добавка к результату
    if name_part =~ /^(.+)(\+)$/
      name_part = $1
      rmethod = "rappend=" # todo prepend
    end
    
    # удобство - замена результата
    if name_part =~ /^(.+)(\=)$/
      name_part = $1
      rmethod = "r="
    end
    
    # собственное значение башенки
    if name_part =~ /^(.+)(\!)$/
      name_part = $1
      assign_mode = true
    end
    
    @machine.log "fixed name_part=#{name_part}, assign_mode=#{assign_mode}, rmethod=#{rmethod}"
    
    lambdum, name_part = generate_lambdum( name_part, rmethod, params, desired_code_id, value )
    # ну вот, и считается теперь, что - кто-то там наверху value преобразовал в то что надо
    
    # тонкий случай - нам надо иногда добавлять куски кода с пустой name_part
    # если это не обработать то получатся символы вида :""
    if name_part == "" || name_part == "nil"
      name_part = nil
    else
      name_part = name_part.to_sym
    end
    
    if assign_mode
      fail if name_part.nil?
      @machine.add_code( name_part, lambdum )
    else
      @machine.add_code( desired_code_id, lambdum )
      @machine.add_cond( [name_part].concat( cond_attrs ), desired_code_id, :prepend => params[:prepend], :ctx_index => 0, :priority => (params[:priority]||0).to_i )
      # { :tag => desired_code_id, :root => true, :name => name_part } было бы прикольно сказать это вместо desired_code_id
      # но! как тогда сделать в случае с name! ? можно конечно сделать перенаправление, т.е. регать add_code name_part+"_own"
      # и добавлять правило - name_part -> { ..., root, ... }
      # короче это надо разрисовать и я все пойму. потому что альтернативный вариант - это вешать
      # поверх всего этого еще одну лямбду.. а ведь еще это надо сочесть с erb.. todo..
    end
  end
  
  def generate_lambdum( name_part, cond_attrs, params, desired_code_id,value )

    fail "вы четтут делаете?"
  
    # @machine.log "default generate_lambdum: name_part=#{name_part.inspect}, cond_attrs=#{cond_attrs}, params=#{params}, codeid=#{desired_code_id}, value=#{value.inspect}"
    lambdum = value.is_a?(Proc) ? value : lambda { |ctx|
      ctx.machine.log "default lambdum called, setting r to value: #{value}"
      ctx.rappend=value 
    }
    return [lambdum,name_part]
  end

end

LetterParser.prepend DasParseTitle