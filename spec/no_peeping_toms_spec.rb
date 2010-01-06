require File.dirname(__FILE__) + '/spec_helper'

module NoPeepingTomsSpec
  class Person < ActiveRecord::Base; end
  
  class PersonObserver < ActiveRecord::Observer
    cattr_accessor :called

    def before_create(person)
      self.class.called = true
    end
  end
  
  class AnotherObserver < ActiveRecord::Observer
    observe Person
    cattr_accessor :called

    def before_create(person)
      self.class.called = true
    end
  end

  describe NoPeepingToms, "configuration" do
    it "enables observers by default" do
      load 'no_peeping_toms.rb'
      NoPeepingToms.default_observers_enabled?.should be_true
    end

    it "runs default observers when default observers are enabled" do
      NoPeepingToms.enable_observers
      PersonObserver.called = false
      Person.create!
      PersonObserver.called.should be_true
    end

    it "does not run default observers when default observers are disabled" do
      NoPeepingToms.disable_observers
      PersonObserver.called = false
      Person.create!
      PersonObserver.called.should be_false
    end
  end

  describe ActiveRecord::Observer, 'with_observers' do
    before(:each) do
      NoPeepingToms.disable_observers
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

    it "should accept anonymous observers" do
      called = false
      observer = Class.new(ActiveRecord::Observer) do
        observe NoPeepingTomsSpec::Person
        define_method(:before_create) {|person| called = true }
      end
      ActiveRecord::Observer.with_observers(observer) { Person.create! }
      called.should be_true
    end

    it "should ensure peeping toms are reset after raised exception" do
      lambda {
        ActiveRecord::Observer.with_observers(NoPeepingTomsSpec::PersonObserver) do
          raise ArgumentError, "Michael, I've made a huge mistake"
        end
      }.should raise_error(ArgumentError)
      ActiveRecord::Observer.peeping_toms.should == []
    end
  end
end
