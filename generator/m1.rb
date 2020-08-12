class CodeMusic
end

Dir[ File.join(__dir__,"m1_*.rb")].sort.each do |f|
#  STDERR.puts "req #{f}"
  require_relative f
end
