require_relative "../../v1.rb"

@machine = CombiningMachine.new

@machine.add_code( :a, lambda{ |ctx|
  puts "a see obj: #{ctx[:request].inspect}"
  ctx.r = ctx.input
} )

@machine.add_code( :b, lambda{ |ctx|
  puts "b see obj: #{ctx[:request].inspect}"
  ctx.r = ctx.r + ctx.r
} )

@machine.append( :foo, :a )
@machine.append( :a, :b )

res = @machine.compute( :foo,[1,2,3],"test" )
puts res.inspect
res == [1,2,3,1,2,3] || fail