# -*- coding: utf-8 -*-

require 'json'
require 'httpclient'
require 'securerandom'

require 'bosonnlp/util'
require 'bosonnlp/mixin'
require 'bosonnlp/version'

# Main class
class Bosonnlp
  include Util
  # Operated task not found on server
  class TaskNotFoundError < StandardError
  end
  # Other task error return by server
  class TaskError < StandardError
  end
  # Http error
  class HTTPError < RuntimeError
  end
  # Task time out.
  class TimeoutError < StandardError
  end

  # Multiple text engine handler
  class MultipleHandler
    include Util
    def initialize(name, http_session, head, multiple_url)
      @name = name
      @http_session = http_session
      @head = head
      @id = SecureRandom.uuid
      @multiple_url = multiple_url
      @alpha = 0.8
      @beta = 0.45
    end

    def pre_process(data)
      fail ArgumentError, 'Wrong args, data must be a list'\
          ' which contains more than one element.'\
        unless Array === data and data.size > 1
      fail ArgumentError, 'Wrong args, data elements must be list of string '\
            'or {_id, text} Hash.'\
        unless String === data[0] or Hash === data[0]

      processd = []
      if String === data[0]
        data.each do |d|
          hash_t = {}
          hash_t['_id'] = SecureRandom.uuid
          hash_t['text'] = d
          processd << hash_t
        end
      else
        processd = data
      end

      processd
    end

    def get_url(method_name)
      @multiple_url % [@name, method_name.to_s, @id]
    end

    def push(*args)
      processd = pre_process args[0]
      request_args = get_hash_args(*args)

      is_ok = false
      processd.each_slice 100 do |s|
        request_args[:body] = s
        res = _http_request(:post, __method__, request_args)
        is_ok = res.ok?
        # TODO, fail for one exception?
      end
      is_ok
    end

    def analysis(*args)
      request_args = get_hash_args(*args)
      request_args['alpha'] ||=  @alpha
      request_args['beta'] ||=  @beta
      res = _http_request(:get, __method__, *args)
      res.ok?
    end

    def status(*args)
      res = _http_request(:get, __method__, *args)
      status = JSON.load(res.content)['status']
      case status.to_s.downcase
      when 'not found'
        raise TaskNotFoundError, "Operated task #{@id} not found on server."
      when 'error'
        raise TaskError, "Task #{@id} failed on server."
      end
      status
    end

    def _wait(timeout)
      time_elapsed = 0.0
      sleep_lenth = 1.0
      while true
        sleep sleep_lenth
        serv_status = status
        return if serv_status.downcase == "done"
        time_elapsed += sleep_lenth
        raise TimeoutError if timeout and time_elapsed > timeout
        sleep_lenth *= 1.5 if sleep_lenth < 2**6
      end
    end

    def result(*args)
      _wait get_hash_args(*args)['timeout']
      res = _http_request(:get, __method__, *args)
      JSON.load(res.content)
    end

    def clear(*args)
      res = _http_request(:get, __method__, *args)
      res.ok?
    end
  end

  def initialize(token = nil)
    @token = token
    @env_token = ENV['BOSON_API_TOKEN']
    proxy = ENV['HTTP_PROXY']
    @http_session = HTTPClient.new(proxy)

    @readable = false
    @fail_on_exception = false
    @base_url = 'http://api.bosonnlp.com'
    @analysis_url =  @base_url + '/%s/analysis'
    @multiple_url =  @base_url + '/%s/%s/%s'

    @token ||= @env_token
    fail 'No API token given or found in environment variables, run '\
        '`export BOSON_API_TOKEN="<your api token>"` in your shell first.'\
      unless @token

    headers = {}
    headers['Accept'] = 'application/json'
    headers['User-Agent'] = "bosonnlp-ruby #{Bosonnlp::VERSION} "\
                            "(httpclient #{HTTPClient::VERSION})"
    headers['Content-Type'] = 'application/json'
    headers['X-Token'] = @token
    @head = headers

    # TODO, args to change default values
  end

  def common_api(name,  *args)
    fail ArgumentError, 'Wrong args, first arg must be a list of string.'\
      unless Array === args[0] and String === args[0][0]

    url = @analysis_url % name

    request_args = args[1] || {}
    request_args[:body] = args[0]

    res = _http_request(:post, url, request_args)
    JSON.load(res.content)
  end

  def create_multiple(name)
    MultipleHandler.new name.to_s, @http_session, @head, @multiple_url
  end

  def multiple_api(name, *args)
    begin
      mh = create_multiple(name)
      mh.push(*args)
      mh.analysis(*args)
      return mh.result
    rescue => e
      puts e.message
      puts e.backtrace.inspect
    ensure
      mh.clear(*args) if mh
    end
  end

  def single_api(name, *args)
    fail ArgumentError, 'Wrong args, data must be a list'\
        ' which contains one and only one string element.'\
      unless Array === args[0] and String === args[0][0] and args[0].size == 1

    url = @analysis_url % name

    request_args = get_hash_args(*args)
    request_args[:body] = args[0][0]

    res = _http_request(:post, url, request_args)
    JSON.load(res.content)
    # :query, :body, :header, :follow_redirect
  end

  def method_missing(name, *args)
    case name.to_s
    when /^c_(.+)$/
      common_api($1, *args)
    when /^m_(.+)$/
      multiple_api($1, *args)
    when /^s_(.+)$/
      single_api($1, *args)
    else
      super
    end
  end
end
