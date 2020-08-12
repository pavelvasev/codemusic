require "pathname"

module DasInputFileTracking
  
  # scope_level помогает нам понимать, какие правила тащить в глубины, а какие нет
  # т.о. если мы хотим явно сказать что надо тащить - это надо явно сказать таки через следующие методы
  def push_file_name( v )
    if defined?(SYSTEM_DIR) && v && v[0] == "/"
      # сократим ко
      STDERR.puts v
      v = Pathname.new(v).relative_path_from(Pathname.new(SYSTEM_DIR)).to_s
    end
  
    @file_name_stack ||= []
    @file_name_stack.push(v)
  end
  
  def pop_file_name
    @file_name_stack.pop
  end
  
  def current_file_name
    (@file_name_stack && @file_name_stack.length > 0 ? @file_name_stack.last : nil)
  end
  
  def parse( text, sourcefile )
    push_file_name sourcefile
    r = super(text)
    pop_file_name
    r
  end
  
  def generate_code_id( name_part )
    r = super
    r = r + "(#{ current_file_name})" if current_file_name
    r
  end

  def include_found_file( f )
    
    self.parse( IO.readlines( f ),f )
  end

end

LetterParser.  prepend DasInputFileTracking
