require File.dirname(__FILE__) + '/spec_helper'

module NoPeepingTomsSpec
  class Person < ActiveRecord::Base; end
  class SpecialPerson < Person; end
  
  class PersonObserver < ActiveRecord::Observer
    cattr_accessor :called

    def before_create(person)
      self.class.called ||= 0
      self.class.called += 1
    end
  end
  
  class AnotherObserver < ActiveRecord::Observer
    observe Person
    cattr_accessor :called

    def before_create(person)
      self.class.called ||= 0
      self.class.called += 1
    end
  end

  # Register the observers with the host app
  PersonObserver.instance
  AnotherObserver.instance

  describe NoPeepingToms, "configuration" do
    it "enables observers by default" do
      load 'no_peeping_toms.rb'
      ActiveRecord::Observer.default_observers_enabled.should be_true
    end

    it "runs default observers when default observers are enabled" do
      ActiveRecord::Observer.enable_observers
      PersonObserver.called = 0
      Person.create!
      PersonObserver.called.should == 1
    end

    it "does not run default observers when default observers are disabled" do
      ActiveRecord::Observer.disable_observers
      PersonObserver.called = 0
      Person.create!
      PersonObserver.called.should == 0
    end

    it "only runs observers once on descendent classes" do
      ActiveRecord::Observer.enable_observers
      PersonObserver.called = 0
      SpecialPerson.create!
      PersonObserver.called.should == 1
    end
  end

  describe ActiveRecord::Observer, 'with_observers' do
    before(:each) do
      ActiveRecord::Observer.disable_observers
    end

    it "should enable an observer via stringified class name" do
      PersonObserver.called = false
      ActiveRecord::Observer.with_observers("NoPeepingTomsSpec::PersonObserver") { Person.create! }
      PersonObserver.called.should be_true
    end

    it "should enable an observer via class" do
      PersonObserver.called = false
      ActiveRecord::Observer.with_observers(NoPeepingTomsSpec::PersonObserver) { Person.create! }
      PersonObserver.called.should be_true
    end

    it "should accept multiple observers" do
      PersonObserver.called = false
      AnotherObserver.called = false
      ActiveRecord::Observer.with_observers(NoPeepingTomsSpec::PersonObserver, NoPeepingTomsSpec::AnotherObserver) do
        Person.create!
      end
      PersonObserver.called.should be_true
      AnotherObserver.called.should be_true
    end

    it "should ensure peeping toms are reset after raised exception" do
      lambda {
        ActiveRecord::Observer.with_observers(NoPeepingTomsSpec::PersonObserver) do
          raise ArgumentError, "Michael, I've made a huge mistake"
        end
      }.should raise_error(ArgumentError)
      ActiveRecord::Observer.observers_enabled.should_not include(NoPeepingTomsSpec::PersonObserver)
    end
  end
end
