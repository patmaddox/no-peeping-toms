if "test" == RAILS_ENV
  ActiveRecord::Observer.send :include, NoPeepingToms
end
