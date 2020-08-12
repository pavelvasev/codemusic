module DasParse
  
  def initialize( machine )
    @machine = machine
  end
  
  def machine=(m)
    @machine=m
  end
  def machine
    @machine
  end

  def parse( text )
    text = text.join if text.is_a?(Array)
    
    #puts "t0",text.inspect
    #text_no_comments = text.gsub( /\/\*[\s\S]*?\*\/|([^:]|^)\/\/.*$/,"" )
    #text_no_comments = text.gsub( /\/\*[\s\S]+?\*\/|([^:]|^)\/\/.*$/,"" )
    # заменил * на плюсик - чтобы хоть что-то было между /* */, так надо для инклюда а то пути вида lib/**/some считаются их куски за комменты..

    parts = text.split(/^##+(?=[^#])/)
    # наелись https://stackoverflow.com/a/18089658 
    # а конкретно добавил скобочки и ?= чтобы после ### не сжирался сивмол
    # раньше было /^##+[^#]/
    
    #итак у нас есть parts - это список записей
    #каждая запись это текст
    #первая строка (до \n) это инфа по заголовку, дальше тело
    
    # теперичо это надо обработать

    for p in parts do
      k = p.index("\n") || -1
      next if k.nil? # пустые строчки

      name = p[0..k].strip
      value = (p[k..-1] || "").strip
      next if name.length == 0 # feature
      #@machine.log "calling process_record name=#{name} value=#{value}"
      process_record( name,value )
    end

  end
  
  def process_record( title, value )
    puts "warning! this is just p1_main debug message. why are you here?"
    puts "title=",title,"value=",value
  end
  
  def machine
    @machine
  end  
  
end

LetterParser.prepend DasParse