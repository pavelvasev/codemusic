require_relative "../machine/v1"
require_relative "../parser/p1"
require_relative "./m1"

SYSTEM_DIR = __dir__
ELEMENTS_DIR=ENV["ELEMENTS_DIR"] || __dir__
TARGET_DIR=ENV["TARGET_DIR"] || "."

txt = STDIN.readlines

cm = CodeMusic.new

cm.eparser.machine.push_scope_level(:all)
cm.eparser.parse( "include {.,#{ELEMENTS_DIR}}/elements/**/*.cm","elements" )
cm.eparser.machine.pop_scope_level

cm.p2parser.parse( "include {.,#{ELEMENTS_DIR}}/elements/**/*.cm2","elements" )

# загрузим ка вход как суб-поле
=begin потом
k3 = CombiningMachine.new( cm.eparser.machine )
k3.name = "main"
k3.parser = cm.eparser
origm = cm.eparser.machine
cm.eparser.machine = k3
cm.eparser.parse( txt )
cm.eparser.machine = origm
# была просто эта строчка
=end
cm.eparser.parse( txt,"stdin" )

res = cm.go

puts res