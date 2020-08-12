# нам надо научиться отслеживать - было ли присваивание
# это надо будет и для полей (чтобы понимать что any пора вызывать)
# и для такой фишки как проверять, были ли присваивания вообще
# ибо если не было то это может означать ошибку (ну зависит от машины)
module MachineContextInputTracking

  def r=(value)
    self[:result_is_assigned] = true
    super
  end
  
  def rappend=(value)
    self[:result_is_assigned] = true
    super
  end
  
  def r_assigned?
    self[:result_is_assigned]
  end
  
end

MachineContext.prepend MachineContextInputTracking