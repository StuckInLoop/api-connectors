=begin
#BitMEX API

### REST API for the BitMEX Trading Platform  [Changelog](/app/apiChangelog)  ----  #### Getting Started   ##### Fetching Data  All REST endpoints are documented below. You can try out any query right from this interface.  Most table queries accept `count`, `start`, and `reverse` params. Set `reverse=true` to get rows newest-first.  Additional documentation regarding filters, timestamps, and authentication is available in [the main API documentation](https://www.bitmex.com/app/restAPI).  *All* table data is available via the [Websocket](/app/wsAPI). We highly recommend using the socket if you want to have the quickest possible data without being subject to ratelimits.  ##### Return Types  By default, all data is returned as JSON. Send `?_format=csv` to get CSV data or `?_format=xml` to get XML data.  ##### Trade Data Queries  *This is only a small subset of what is available, to get you started.*  Fill in the parameters and click the `Try it out!` button to try any of these queries.  * [Pricing Data](#!/Quote/Quote_get)  * [Trade Data](#!/Trade/Trade_get)  * [OrderBook Data](#!/OrderBook/OrderBook_getL2)  * [Settlement Data](#!/Settlement/Settlement_get)  * [Exchange Statistics](#!/Stats/Stats_history)  Every function of the BitMEX.com platform is exposed here and documented. Many more functions are available.  ---  ## All API Endpoints  Click to expand a section. 

OpenAPI spec version: 1.2.0
Contact: support@bitmex.com
Generated by: https://github.com/swagger-api/swagger-codegen.git

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

=end

require 'spec_helper'

describe SwaggerClient::ApiClient do
  context 'initialization' do
    context 'URL stuff' do
      context 'host' do
        it 'removes http from host' do
          SwaggerClient.configure { |c| c.host = 'http://example.com' }
          expect(SwaggerClient::Configuration.default.host).to eq('example.com')
        end

        it 'removes https from host' do
          SwaggerClient.configure { |c| c.host = 'https://wookiee.com' }
          expect(SwaggerClient::ApiClient.default.config.host).to eq('wookiee.com')
        end

        it 'removes trailing path from host' do
          SwaggerClient.configure { |c| c.host = 'hobo.com/v4' }
          expect(SwaggerClient::Configuration.default.host).to eq('hobo.com')
        end
      end

      context 'base_path' do
        it "prepends a slash to base_path" do
          SwaggerClient.configure { |c| c.base_path = 'v4/dog' }
          expect(SwaggerClient::Configuration.default.base_path).to eq('/v4/dog')
        end

        it "doesn't prepend a slash if one is already there" do
          SwaggerClient.configure { |c| c.base_path = '/v4/dog' }
          expect(SwaggerClient::Configuration.default.base_path).to eq('/v4/dog')
        end

        it "ends up as a blank string if nil" do
          SwaggerClient.configure { |c| c.base_path = nil }
          expect(SwaggerClient::Configuration.default.base_path).to eq('')
        end
      end
    end
  end

  describe "#update_params_for_auth!" do
    it "sets header api-key parameter with prefix" do
      SwaggerClient.configure do |c|
        c.api_key_prefix['api_key'] = 'PREFIX'
        c.api_key['api_key'] = 'special-key'
      end

      api_client = SwaggerClient::ApiClient.new

      config2 = SwaggerClient::Configuration.new do |c|
        c.api_key_prefix['api_key'] = 'PREFIX2'
        c.api_key['api_key'] = 'special-key2'
      end
      api_client2 = SwaggerClient::ApiClient.new(config2)

      auth_names = ['api_key', 'unknown']

      header_params = {}
      query_params = {}
      api_client.update_params_for_auth! header_params, query_params, auth_names
      expect(header_params).to eq({'api_key' => 'PREFIX special-key'})
      expect(query_params).to eq({})

      header_params = {}
      query_params = {}
      api_client2.update_params_for_auth! header_params, query_params, auth_names
      expect(header_params).to eq({'api_key' => 'PREFIX2 special-key2'})
      expect(query_params).to eq({})
    end

    it "sets header api-key parameter without prefix" do
      SwaggerClient.configure do |c|
        c.api_key_prefix['api_key'] = nil
        c.api_key['api_key'] = 'special-key'
      end

      api_client = SwaggerClient::ApiClient.new

      header_params = {}
      query_params = {}
      auth_names = ['api_key', 'unknown']
      api_client.update_params_for_auth! header_params, query_params, auth_names
      expect(header_params).to eq({'api_key' => 'special-key'})
      expect(query_params).to eq({})
    end
  end

  describe "params_encoding in #build_request" do
    let(:config) { SwaggerClient::Configuration.new }
    let(:api_client) { SwaggerClient::ApiClient.new(config) }

    it "defaults to nil" do
      expect(SwaggerClient::Configuration.default.params_encoding).to eq(nil)
      expect(config.params_encoding).to eq(nil)

      request = api_client.build_request(:get, '/test')
      expect(request.options[:params_encoding]).to eq(nil)
    end

    it "can be customized" do
      config.params_encoding = :multi
      request = api_client.build_request(:get, '/test')
      expect(request.options[:params_encoding]).to eq(:multi)
    end
  end

  describe "timeout in #build_request" do
    let(:config) { SwaggerClient::Configuration.new }
    let(:api_client) { SwaggerClient::ApiClient.new(config) }

    it "defaults to 0" do
      expect(SwaggerClient::Configuration.default.timeout).to eq(0)
      expect(config.timeout).to eq(0)

      request = api_client.build_request(:get, '/test')
      expect(request.options[:timeout]).to eq(0)
    end

    it "can be customized" do
      config.timeout = 100
      request = api_client.build_request(:get, '/test')
      expect(request.options[:timeout]).to eq(100)
    end
  end

  describe "#deserialize" do
    it "handles Array<Integer>" do
      api_client = SwaggerClient::ApiClient.new
      headers = {'Content-Type' => 'application/json'}
      response = double('response', headers: headers, body: '[12, 34]')
      data = api_client.deserialize(response, 'Array<Integer>')
      expect(data).to be_instance_of(Array)
      expect(data).to eq([12, 34])
    end

    it "handles Array<Array<Integer>>" do
      api_client = SwaggerClient::ApiClient.new
      headers = {'Content-Type' => 'application/json'}
      response = double('response', headers: headers, body: '[[12, 34], [56]]')
      data = api_client.deserialize(response, 'Array<Array<Integer>>')
      expect(data).to be_instance_of(Array)
      expect(data).to eq([[12, 34], [56]])
    end

    it "handles Hash<String, String>" do
      api_client = SwaggerClient::ApiClient.new
      headers = {'Content-Type' => 'application/json'}
      response = double('response', headers: headers, body: '{"message": "Hello"}')
      data = api_client.deserialize(response, 'Hash<String, String>')
      expect(data).to be_instance_of(Hash)
      expect(data).to eq({:message => 'Hello'})
    end

    it "handles Hash<String, Pet>" do
      api_client = SwaggerClient::ApiClient.new
      headers = {'Content-Type' => 'application/json'}
      response = double('response', headers: headers, body: '{"pet": {"id": 1}}')
      data = api_client.deserialize(response, 'Hash<String, Pet>')
      expect(data).to be_instance_of(Hash)
      expect(data.keys).to eq([:pet])

      pet = data[:pet]
      expect(pet).to be_instance_of(SwaggerClient::Pet)
      expect(pet.id).to eq(1)
    end

    it "handles Hash<String, Hash<String, Pet>>" do
      api_client = SwaggerClient::ApiClient.new
      headers = {'Content-Type' => 'application/json'}
      response = double('response', headers: headers, body: '{"data": {"pet": {"id": 1}}}')
      result = api_client.deserialize(response, 'Hash<String, Hash<String, Pet>>')
      expect(result).to be_instance_of(Hash)
      expect(result.keys).to match_array([:data])

      data = result[:data]
      expect(data).to be_instance_of(Hash)
      expect(data.keys).to match_array([:pet])

      pet = data[:pet]
      expect(pet).to be_instance_of(SwaggerClient::Pet)
      expect(pet.id).to eq(1)
    end
  end

  describe "#object_to_hash" do
    it "ignores nils and includes empty arrays" do
      api_client = SwaggerClient::ApiClient.new
      pet = SwaggerClient::Pet.new
      pet.id = 1
      pet.name = ''
      pet.status = nil
      pet.photo_urls = nil
      pet.tags = []
      expected = {id: 1, name: '', tags: []}
      expect(api_client.object_to_hash(pet)).to eq(expected)
    end
  end

  describe "#build_collection_param" do
    let(:param) { ['aa', 'bb', 'cc'] }
    let(:api_client) { SwaggerClient::ApiClient.new }

    it "works for csv" do
      expect(api_client.build_collection_param(param, :csv)).to eq('aa,bb,cc')
    end

    it "works for ssv" do
      expect(api_client.build_collection_param(param, :ssv)).to eq('aa bb cc')
    end

    it "works for tsv" do
      expect(api_client.build_collection_param(param, :tsv)).to eq("aa\tbb\tcc")
    end

    it "works for pipes" do
      expect(api_client.build_collection_param(param, :pipes)).to eq('aa|bb|cc')
    end

    it "works for multi" do
      expect(api_client.build_collection_param(param, :multi)).to eq(['aa', 'bb', 'cc'])
    end

    it "fails for invalid collection format" do
      expect(proc { api_client.build_collection_param(param, :INVALID) }).to raise_error(RuntimeError, 'unknown collection format: :INVALID')
    end
  end

  describe "#json_mime?" do
    let(:api_client) { SwaggerClient::ApiClient.new }

    it "works" do
      expect(api_client.json_mime?(nil)).to eq false
      expect(api_client.json_mime?('')).to eq false

      expect(api_client.json_mime?('application/json')).to eq true
      expect(api_client.json_mime?('application/json; charset=UTF8')).to eq true
      expect(api_client.json_mime?('APPLICATION/JSON')).to eq true

      expect(api_client.json_mime?('application/xml')).to eq false
      expect(api_client.json_mime?('text/plain')).to eq false
      expect(api_client.json_mime?('application/jsonp')).to eq false
    end
  end

  describe "#select_header_accept" do
    let(:api_client) { SwaggerClient::ApiClient.new }

    it "works" do
      expect(api_client.select_header_accept(nil)).to be_nil
      expect(api_client.select_header_accept([])).to be_nil

      expect(api_client.select_header_accept(['application/json'])).to eq('application/json')
      expect(api_client.select_header_accept(['application/xml', 'application/json; charset=UTF8'])).to eq('application/json; charset=UTF8')
      expect(api_client.select_header_accept(['APPLICATION/JSON', 'text/html'])).to eq('APPLICATION/JSON')

      expect(api_client.select_header_accept(['application/xml'])).to eq('application/xml')
      expect(api_client.select_header_accept(['text/html', 'application/xml'])).to eq('text/html,application/xml')
    end
  end

  describe "#select_header_content_type" do
    let(:api_client) { SwaggerClient::ApiClient.new }

    it "works" do
      expect(api_client.select_header_content_type(nil)).to eq('application/json')
      expect(api_client.select_header_content_type([])).to eq('application/json')

      expect(api_client.select_header_content_type(['application/json'])).to eq('application/json')
      expect(api_client.select_header_content_type(['application/xml', 'application/json; charset=UTF8'])).to eq('application/json; charset=UTF8')
      expect(api_client.select_header_content_type(['APPLICATION/JSON', 'text/html'])).to eq('APPLICATION/JSON')
      expect(api_client.select_header_content_type(['application/xml'])).to eq('application/xml')
      expect(api_client.select_header_content_type(['text/plain', 'application/xml'])).to eq('text/plain')
    end
  end

  describe "#sanitize_filename" do
    let(:api_client) { SwaggerClient::ApiClient.new }

    it "works" do
      expect(api_client.sanitize_filename('sun')).to eq('sun')
      expect(api_client.sanitize_filename('sun.gif')).to eq('sun.gif')
      expect(api_client.sanitize_filename('../sun.gif')).to eq('sun.gif')
      expect(api_client.sanitize_filename('/var/tmp/sun.gif')).to eq('sun.gif')
      expect(api_client.sanitize_filename('./sun.gif')).to eq('sun.gif')
      expect(api_client.sanitize_filename('..\sun.gif')).to eq('sun.gif')
      expect(api_client.sanitize_filename('\var\tmp\sun.gif')).to eq('sun.gif')
      expect(api_client.sanitize_filename('c:\var\tmp\sun.gif')).to eq('sun.gif')
      expect(api_client.sanitize_filename('.\sun.gif')).to eq('sun.gif')
    end
  end
end