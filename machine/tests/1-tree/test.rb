require_relative "../../v1.rb"

@machine = CombiningMachine.new

@machine.add_code( :a, lambda{ |ctx|
  puts "a self=#{self.inspect}"
  puts "a see obj: #{ctx[:request].inspect}"
} )

@machine.add_code( :b, lambda{ |ctx|
  puts "b see obj: #{ctx[:request].inspect}"
  puts "b see input: #{ctx[:input].inspect}"
  puts "b call input: #{ctx.input}"
  puts "b call tree_input: #{ctx.tree_input}"
  #ctx[:result]
  ctx.r = ctx.input[0]+1
} )

@machine.add_code( :c, lambda{ |ctx|
  puts "c see obj: #{ctx[:request].inspect}"
  puts "c see input: #{ctx.input}"
  ctx[:result] = ctx.input.length
} )

@machine.append( :foo, :a )
@machine.append( :a, :b )

res = @machine.compute( {:tag => :foo, :items => [{ :tag => :c, :items => [:tdata]}]}, [1,2,3], "test" )

puts "res=#{res}"
res == 4 || fail
puts "finished!"