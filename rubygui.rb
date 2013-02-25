require 'gtk2'

module Gui
  class Button
    attr_reader :obj
  
    def initialize(parent, text = "Button")
      @obj = Gtk::Button.new(text)
      parent.add(self)
    end
  
    def on_click
      @obj.signal_connect("clicked") do
        yield
      end
      self
    end
  end
  
  class ProgressBar
    attr_reader :obj
    
    def initialize(parent, total = 100, text = nil)
      @obj = Gtk::ProgressBar.new
      parent.add(self)
      @total = total
      @obj.fraction = 0
      @obj.text = text
    end
    
    def set(i)
      @obj.fraction = i.to_f / @total
    end
  end
  
  class Scale
    attr_reader :obj
    
    def initialize(parent, options)
      min  = options[:min] || 0
      max  = options[:max] || 100
      step = options[:step] || (max-min).to_f/100
      @obj = Gtk::HScale.new(min, max, step)
      @obj.value_pos = Gtk::POS_RIGHT
      parent.add(self)
    end
  end

  module Container
    attr_reader :root
    
    def create_child(name = nil, hash = {})
      hash = name if name.is_a?(Hash)
      hash = {:text => hash} unless hash.is_a?(Hash)
      hash[:text] = name if name.is_a?(String) && hash[:text].nil?
      child = yield(hash)
      @root.define_child(name, child)
      child
    end
    
    def button(name = nil, hash = {})
      create_child(name, hash) do |hash|
        Button.new(self, hash[:text])
      end
    end
  
    def progress(name = nil, hash = {})
      create_child(name, hash) do |hash|
        ProgressBar.new(self, 100, hash[:text])
      end
    end
    
    def scale(name = nil, hash = {})
      create_child(name, hash) do |hash|
        Scale.new(self, hash)
      end
    end
    
    def hbox(&block)
      hbox = HBox.new(@root, self)
      hbox.instance_eval(&block)
    end
  
    def vbox(&block)
      vbox = VBox.new(@root, self)
      vbox.instance_eval(&block)
    end
  
    def method_missing(action, *args)
      @root.send(action, *args)
    end
  end
  
  class HBox
    include Container
    
    attr_reader :obj
    
    def initialize(root, parent)
      @root = root
      @obj = Gtk::HBox.new(false, 4)
      parent.add(self)
    end
    
    def add(item)
      @obj.pack_start(item.obj, true, true, 0)
    end
  end
  
  class VBox
    include Container
    
    attr_reader :obj
    
    def initialize(root, parent)
      @root = root
      @obj = Gtk::VBox.new(false, 4)
      parent.add(self)
    end
    
    def add(item)
      @obj.pack_start(item.obj, true, true, 0)
    end
  end
  
  class Window
    include Container
    
    attr_reader :obj
    
    def initialize(text = __FILE__)
      @root = self
      @obj = Gtk::Window.new
      @obj.title = text
      @obj.border_width = 10
      @obj.signal_connect("destroy") do
        Gtk.main_quit
      end
      
      @children = {}
    end
    
    def build(&block)
      instance_eval(&block)
    end
    
    def add(item)
      @obj.add(item.obj)
    end
    
    def title=(text)
      @obj.title = text
    end
    
    def show
      @obj.show_all
      Gtk.main
    end
  
    def define_child(name, item)
      return unless name.is_a? Symbol
      name_s = name.to_s
      raise "'#{name_s}' is already defined!" unless @children[name].nil?
      raise "'#{name_s}' cannot be used as name!" if methods.include?(name)
      @children[name] = item
      instance_eval "def #{name_s}
        @children[:#{name_s}]
      end"
    end
  
    def method_missing(action, *args)
      raise "'#{action}' is not defined!"
    end
  end
end
