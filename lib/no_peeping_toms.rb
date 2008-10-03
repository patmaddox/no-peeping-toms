module NoPeepingToms
  def with_observers(*observer_syms)
    observer_names = [observer_syms].flatten
    observers = observer_names.map do |o| 
      if o.respond_to?(:instance) && o.instance.is_a?(ActiveRecord::Observer)
        o.instance
      else
        o.to_s.classify.constantize.instance 
      end
    end
    
    observers.each { |o| old_add_observer(o) }
    yield
    observers.each { |o| delete_observer(o) }
  end
end
