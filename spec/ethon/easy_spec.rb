require 'spec_helper'

describe Ethon::Easy do
  let(:easy) { Ethon::Easy.new }

  describe ".new" do
    it "inits curl" do
      Ethon::Curl.expects(:init)
      easy
    end

    it "defines finalizer" do
      ObjectSpace.expects(:define_finalizer)
      easy
    end

    context "when options are empty" do
      it "sets nothing" do
        easy.instance_variables.all? { |ivar| ivar == nil }.should be_true
      end
    end

    context "when options not empty" do
      context "when verbose is set" do
        let(:options) { { :verbose => true } }
        let(:easy) { Ethon::Easy.new(options) }

        it "sets verbose" do
          easy.verbose.should be_true
        end
      end
    end
  end

  describe "#set_attributes" do
    context "when options are empty" do
      it "sets nothing" do
        easy.instance_variables.all? { |ivar| ivar == nil }.should be_true
      end
    end

    context "when options aren't empty" do
      context "when valid key" do
        it "sets" do
          easy.set_attributes({:verbose => true})
          easy.verbose.should be_true
        end
      end

      context "when invalid key" do
        it "raises invalid option error" do
          expect{ easy.set_attributes({:fubar => 1}) }.to raise_error(Ethon::Errors::InvalidOption)
        end
      end
    end
  end

  describe "#handle" do
    it "returns a pointer" do
      easy.handle.should be_a(FFI::Pointer)
    end
  end

  describe "#reset" do
    let(:resettables) { easy.instance_variables - [:@handle, :@header_list, '@handle', '@header_list'] }

    before do
      easy.class.available_options.each do |option|
        easy.method("#{option}=").call(1)
      end
    end

    it "sets instance variables to nil" do
      easy.reset
      resettables.map{|ivar| easy.instance_variable_get(ivar) }.any?.should be_false
    end

    it "resets easy handle" do
      Ethon::Curl.expects(:easy_reset)
      easy.reset
    end
  end

  describe "#to_hash" do
    [
      :return_code, :response_code, :response_header, :response_body,
      :total_time, :starttransfer_time, :appconnect_time,
      :pretransfer_time, :connect_time, :namelookup_time,
      :effective_url, :primary_ip, :redirect_count
    ].each do |name|
      it "contains #{name}" do
        easy.to_hash.should include(name)
      end
    end
  end

  describe ".finalizer" do
    it "calls easy_cleanup" do
      Ethon::Curl.expects(:easy_cleanup).with(easy.handle)
      Ethon::Easy.finalizer(easy).call
    end

    context "when header_list" do
      before { easy.instance_variable_set(:@header_list, 1) }

      it "calls slist_free_all" do
        Ethon::Curl.expects(:slist_free_all).with(easy.header_list)
        Ethon::Easy.finalizer(easy).call
      end
    end
  end
end
