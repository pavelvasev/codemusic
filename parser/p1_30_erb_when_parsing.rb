# забано получается, что точки куда соединяться - это имена методов
# а суть фишки - это имя модуля
# а названия кодов вообще не фигурируют (хотя я могу вручную их создать)

module DasParseErbOnline
  
  def process_record( title, value )
    if title =~ /^erb\s?.*$/
      @machine.log "erb: executing during parse"
      erb = ERB.new( value ) # можно % добавить но я не вижу в нем смысла - только засоряет эфир плюс может вдруг безопасность нарушит
      erb.filename = "[pismo]"
      r = erb.result( binding )
      @machine.log "****** erb executed. applying result *******"
      @machine.log r
      @machine.log "********************************************"
      self.parse( r,"erb-in-source(#{current_file_name})" )
    else
      #@machine.log "erb: the title is not my, title=#{title}"
      super
    end
  end
  
end

LetterParser.prepend DasParseErbOnline