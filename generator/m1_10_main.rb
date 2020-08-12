module DasMainMusic
  
  def initialize
    @emachine = CombiningMachine.new
    @emachine.name = "emachine"
    @eparser = LetterParser.new( @emachine )
    @emachine.parser = @eparser
    
    @p2machine = CombiningMachine.new
    @p2machine.name = "p2machine"
    @p2parser = LetterParser.new( @p2machine )
    
    @emachine.log "----- mainmusic inited. ready to work."
  end
  
  attr_reader :eparser
  attr_reader :p2parser
  
  def go
    @emachine.log "----- mainmusic: computing e-pass."
    r = @emachine.compute( :main,[],"mainmusic::go" )
    @emachine.log "----- mainmusic: computing p2-pass."
    rr = @p2machine.compute( r, [], "mainmusig::go" )
    @emachine.log "----- mainmusic: finished."
    rr
  end
  
end

CodeMusic.prepend DasMainMusic