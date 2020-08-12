# ссылка на парсер
# но на самом деле нам надо не парсер, а контекст для руби
# ну ладно, потом сделаем нормальный контекст

module DasKnowParser

  def parser=(v)
    @parser=v
  end
  
  def parser
    @parser
  end

end


CombiningMachine.  prepend DasKnowParser

