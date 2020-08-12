require_relative "../../v1.rb"

@machine = CombiningMachine.new

@machine.add_code( :a, lambda{ |ctx|
  ctx.r = ctx.r + [55]
} )

@machine.add_code( :b, lambda{ |ctx|
  STDERR.puts "b called. ctx.obj = #{ctx.obj.inspect}, ctx.input=#{ctx.input}"
  ctx.r = ctx.r + [ctx.obj[:qq]] + ctx.input[0]
} )

@machine.add_code( :c, lambda{ |ctx|
  STDERR.puts ">> c input=#{ctx.input}"
  ctx.r = ctx.input
} )

@machine.append( :foo, :a )
@machine.append( [:foo,:qq], :b )

code = {:tag => :foo, 
        :items => [
          { :tag => :c, 
            :items => [:tdata]
          },
          {
            :tag => :attr,
            :name => "qq",
            :value => 56
          }
        ]
       }

res = @machine.compute( code, [1,2,3],"test" )

puts "res=#{res}"
res == [55, 56, 1, 2, 3] || fail
