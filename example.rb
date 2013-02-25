require './rubygui.rb'

win = Gui::Window.new("Hello")

win.build do
  vbox do
    hbox do
      progress(:bar1, :text => "progress1")
  
      button("test").on_click do
        bar1.set(50)
      end
      
      button(:text => "test2").on_click do
        bar2.set(100)
      end
  
      progress(:bar2)
      progress(:bar3, "progress3")
      progress("progress4")
    end
  
    hbox do
      button(:text => "test2").on_click do
        bar3.set(100)
      end
    end
  end
end

win.show


