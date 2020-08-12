module DasArrayCompute

  # простой способ совмещения вычисления массива... потом вообще-то может улушчить
  # например соединять в 1 общий массив как в двидиум (но я не вижу причины дл яэтого)
  # а может совмещать как в compute_chain.. но тогда получается аргументы это как программа становится..
  # что в принципе забавно..
  def compute( request, args, comment )
    if !request.is_a?(Array)
      return super
    end
    # это такая оптимизация, если всего 1 вызов в массиве - нефиг упаковывать в еще один массив
    # потому что а как же вызывать tdata?
    if request.length == 1 && (request[0] == :tdata || (request[0].is_a?(Hash) && request[0][:tag] == :tdata && request[0][:get].nil?)) 
      # пока так сделаем - соломоно решение это или нет? ))
      # хаха, но у tdata get не должно быть указано при этом!
    
      # а вообще правильно что я вот так вот опираюсь на эту историю с символами? может это как-то универсальнее делать?
      #STDERR.puts "array compute patched!"
      # но возникает другая проблемко - вызвали нам вычисление например 
      # "[10]" (из xml-я).. и по идее - нам надо бы и вернуть это в виде массива, не?
      # хм.. но и с tdata ситуация ясна, он иначе запакуется в 1 элемент..
      # не знаю как быть тут.. ваще не понимаю..
      return super( request[0],args,comment )
    end

    result = []
    request.each do |req|
      r = compute( req, args,"arr" )
      result.push( r )
    end

    result
  end
end


CombiningMachine.  prepend DasArrayCompute

