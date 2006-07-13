require 'mocha_class'

class Module
  
  def mochas
    @@mochas ||= {}
  end
  
  def reset_mochas
    @@mochas = nil
  end

  def const_missing(symbol)
    mochas[symbol] ||= MochaClass.dup
  end
  
  def verify_all
    mochas.each_value { |mocha| mocha.verify_all }
  end
  
end

MochaClass.class_eval do
  
  class << self
    
    def mochas
      @mochas ||= {}
    end

    def const_missing(symbol)
      mochas[symbol] ||= MochaClass.dup
    end
    
    def verify_all
      mochas.each_value { |mocha| mocha.verify }
      verify
    end
    
  end

end

class Test::Unit::TestCase
  
  def reset_mochas
    Object.reset_mochas
  end
   
  def verify_all
    Object.verify_all
  end
  
end