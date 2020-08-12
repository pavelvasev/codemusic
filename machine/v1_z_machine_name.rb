module DasMachineWithName

  def name
    @name
  end

  def name=(v)
    @name=v
  end
  
  def to_s
    "CombiningMachine::#{self.name}"
  end
  
  def inspect
    to_s
  end

end

CombiningMachine.  prepend DasMachineWithName
