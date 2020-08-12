require_relative "../../v1.rb"

@machine = CombiningMachine.new

@machine.add_code( :a, lambda{ |ctx|
  ctx.r = ctx.r + ["a"]
} )

@machine.add_code( :b, lambda{ |ctx|
  ctx.r = ctx.r + ["b"]
} )

@machine.add_code( :c, lambda{ |ctx|
  ctx.r = ctx.r + ["c"]
} )

@machine.append( :foo, :a )
@machine.append( [:foo,:qq], :b, :priority => 5 )

code = {:tag => :foo, :qq => 33}

res = @machine.compute( code, [1,2,3],"test" )

puts "res=#{res}"
res == ["b","a"] || fail
