class CombiningMachine
end

class MachineContext < Hash
end

Dir[ File.join(__dir__,"v1_*.rb")].sort.each do |f|
#  STDERR.puts "req #{f}"
  require_relative f
end
