module DasParseComments

  def parse( text )
    text = text.join if text.is_a?(Array)
    
    #puts "t0",text.inspect
    #text_no_comments = text.gsub( /\/\*[\s\S]*?\*\/|([^:]|^)\/\/.*$/,"" )
    ##text_no_comments = text.gsub( /\/\*[\s\S]+?\*\/|([^:]|^)\/\/.*$/,"" )
    # заменил * на плюсик - чтобы хоть что-то было между /* */, так надо для инклюда а то пути вида lib/**/some считаются их куски за комменты..
    # короче выяснилось что мне // и /* */ нужны - при генерации qml
    # засим свои комментарии
    
    # //
    # /* */
    # =begin
    # =end
    # ``
    # <!-- .. -->
    
    # ну короче пока такое решение.. хотя уже видно, что это все попахивает заменой..
    #text_no_comments = text.gsub( /\/\*[\s\S]+?\*\/|([^:]|^)\/\/.*$/,"" )
    #text_no_comments.gsub!( /\\\/\\\//,"//" )
    #text_no_comments.gsub!( /``.*$/,"" ) # все-таки мои комменты тоже.. как-то надежнее
    
    # короче, будут наши комменты
    # `` однострочный, ``` многострочный
    text_no_comments = text.gsub( /```[\s\S]+?```|``.*$/,"" )
    
    # фигня, надо-ело экранировать, в js-кодах // встречаются.. их тоже надо экранить получается..
    # text_no_comments = text.gsub( /\=begin[\s\S]+?=end|([^:]|^)``.*$/,"" )
    
    super( text_no_comments )
  end
  
end

LetterParser.prepend DasParseComments