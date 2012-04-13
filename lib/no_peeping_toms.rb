require 'active_record'
require 'active_support/core_ext/class/attribute_accessors'
require 'active_support/core_ext/string/inflections'

module NoPeepingToms
  extend ActiveSupport::Concern

  included do
    # Define class-level accessors
    cattr_accessor :default_observers_enabled, :observers_enabled

    # By default, enable all observers
    enable_observers
    self.observers_enabled = []

    alias_method_chain :define_callbacks, :enabled_check
  end

  module ClassMethods
    # Enables all observers (default behavior)
    def enable_observers
      self.default_observers_enabled = true
    end

    # Disables all observers
    def disable_observers
      self.default_observers_enabled = false
    end

    # Run a block with a specific set of observers enabled
    def with_observers(*observer_syms)
      self.observers_enabled = Array(observer_syms).map do |o|
        o.respond_to?(:instance) ? o.instance : o.to_s.classify.constantize.instance
      end
      yield
    ensure
      self.observers_enabled = []
    end

    # Determines whether an observer is enabled.  Either:
    # - All observers are enabled OR
    # - The observer is in the whitelist
    def observer_enabled?(observer)
      default_observers_enabled or self.observers_enabled.include?(observer)
    end
  end

  # Overrides ActiveRecord#define_callbacks so that observers are only called
  # when enabled.
  #
  # This is a bit yuck being a protected method, but appears to be the cleanest
  # way so far
  def define_callbacks_with_enabled_check(klass)
    observer = self
    observer_name = observer.class.name.underscore.gsub('/', '__')

    ActiveRecord::Callbacks::CALLBACKS.each do |callback|
      next unless respond_to?(callback)
      callback_meth = :"_notify_#{observer_name}_for_#{callback}"
      unless klass.respond_to?(callback_meth)
        klass.send(:define_method, callback_meth) do
          observer.send(callback, self) if observer.observer_enabled?
        end
        klass.send(callback, callback_meth)
      end
    end
  end

  # Determines whether this observer should be run
  def observer_enabled?
    self.class.observer_enabled?(self)
  end
end

ActiveRecord::Observer.__send__ :include, NoPeepingToms
