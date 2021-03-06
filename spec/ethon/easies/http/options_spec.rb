require 'spec_helper'

describe Ethon::Easies::Http::Options do
  let(:easy) { Ethon::Easy.new }
  let(:url) { "http://localhost:3001/" }
  let(:params) { nil }
  let(:form) { nil }
  let(:options) { described_class.new(url, {:params => params, :body => form}) }

  describe "#setup" do
    before { options.setup(easy) }

    it "sets customrequest" do
      easy.customrequest.should eq("OPTIONS")
    end

    it "sets url" do
      easy.url.should eq(url)
    end

    context "when requesting" do
      let(:params) { {:a => "1&b=2"} }

      before do
        easy.prepare
        easy.perform
      end

      it "returns ok" do
        easy.return_code.should eq(:ok)
      end

      it "is a options request" do
        easy.response_body.should include('"REQUEST_METHOD":"OPTIONS"')
      end

      it "requests parameterized url" do
        easy.effective_url.should eq("http://localhost:3001/?a=1%26b%3D2")
      end
    end
  end
end
