# забано получается, что точки куда соединяться - это имена методов
# а суть фишки - это имя модуля
# а названия кодов вообще не фигурируют (хотя я могу вручную их создать)

module DasParseInclude
  
  def process_record( title, value )
    if title =~ /^include (.+)$/
      #@machine.log "include: title=#{title}"
      file = $1
      #path = "{.}/#{file}"
      # ну тут вопрос путей
      #path = "{.,#{File.join SYSTEM_ROOT,TARGET}}/#{file}"
      # выяснилось что похоже лучше пути то где-то выше настраивать...
      # хотя тоже хз.. получается они будут относительно некоей текущей директории.. (по отношению к программе, не к файлу..)
      path = file
      
      foundfiles = Dir.glob( path ).sort
      @machine.log "include: #{path} found files: #{foundfiles}"
      for foundfile in foundfiles do
        #self.parse( IO.readlines( foundfile ) )
        self.include_found_file( foundfile )
      end
    else
      super
    end
  end
  
  # заменится методом из слоя p1_70_input_file_tracking
  def include_found_file( f )
    self.parse( IO.readlines( f ) )
  end
  
end

LetterParser.prepend DasParseInclude