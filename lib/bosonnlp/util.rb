class Bosonnlp
  # 'Utils'
  module Util
    def get_hash_args(*args)
      if Hash === args[-1]
        h = args[-1]
      else
        h = {}
      end
      h
    end

    # :query, :body, :header, :follow_redirect
    def _http_request(method, url, *args)
      request_args = get_hash_args(*args)
      url = get_url url unless url.to_s.start_with?('http://')
      request_args[:header] = @head
      request_args[:body] = \
        JSON.dump(request_args[:body]) if request_args[:body]

      res = @http_session.request(method, url, request_args)
      status = res.status
      raise HTTPError, 'HTTPError: %s %s'\
        % [status, (JSON.load(res.content)['message'] rescue res.reason)]\
        if status >= 400 && status < 600
      res
    end
  end
end
