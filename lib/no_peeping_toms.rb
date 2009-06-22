module NoPeepingToms
  def self.included(base)
    base.send :include, NoPeepingToms::InstanceMethods
    base.extend NoPeepingToms::ClassMethods
    base.alias_method_chain :update, :neighborhood_watch
    base.cattr_accessor :allow_peeping_toms, :peeping_toms
    base.allow_peeping_toms = false
    base.peeping_toms = [] # toms that are allowed to peep
  end

  module InstanceMethods
    def update_with_neighborhood_watch(*args)
      if self.class.allow_peeping_toms || self.class.peeping_toms.include?(self)
        update_without_neighborhood_watch(*args)
      end
    end
  end
  
  module ClassMethods
    def with_observers(*observer_syms)
      self.peeping_toms = Array(observer_syms).map do |o| 
        o.respond_to?(:instance) ? o.instance : o.to_s.classify.constantize.instance
      end
      yield
    ensure
      self.peeping_toms.clear
    end
  end
end
