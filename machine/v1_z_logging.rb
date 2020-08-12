module DasLogging
  def log( msg )
    @log_padding ||= 0
    STDERR.puts "#{' ' *@log_padding}#{msg}"
    if block_given?
      @log_padding = @log_padding + 1
      r=yield
      @log_padding = @log_padding - 1
      r
    end
  end
  
  def add_cond(*args)
    log "add_cond: #{args[0].inspect} (code=#{args[1].inspect})" do
      super
    end
  end
  
  def compute(*args)
    r=log "compute(#{args[2]}): #{args[0].inspect} (data=#{args[1].inspect})" do
      super
    end
    #log "compute res=#{r}"
    r
  end
  
  def compute_in_context(*args)
    log "compute_in_context: #{args[0].inspect}" do
      super
    end
  end  
  
end

CombiningMachine.prepend DasLogging