# позволяет коду выяснить самого себя и тех кто его вызывал
# возможно code_track это не то название.. возможно надо obj_stack или типа того..

module DasCodeTrack

  def compute_chain( arr,request )
    ctx[:code_track] ||= []
    ctx[:code_track].push request
    cc_res = super
    ctx[:code_track].pop
    cc_res
  end
  
end


CombiningMachine.  prepend DasCodeTrack

