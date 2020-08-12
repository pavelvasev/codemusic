require_relative "./../machine/v1"
require_relative "./p1"

txt = STDIN.readlines
#puts "got txt"
#puts txt.inspect

machine = CombiningMachine.new
parser = LetterParser.new( machine )

parser.parse( txt.join )

res = machine.compute( :main,[],"parser" )
#puts "res=",res.inspect
puts res