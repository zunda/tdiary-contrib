# -*- coding: utf-8 -*-
#
# yo_update.rb - Yo all when an entry or a comment is posted
#
# Copyright (C) 2014, zunda <zundan at gmail.com>
#
# Permission is granted for use, copying, modification,
# distribution, and distribution of modified versions of this
# work under the terms of GPL version 2 or later.
#
# TODO: Add the button to subscribe
# TODO: Configuration interface in Japanese
# TODO: Instraction to obtain API key, through http://dev.justyo.co/ ?
#

require 'uri'
require 'timeout'
require 'net/http'
require 'json'

YO_UPDATE_TIMEOUT = 10

class YoUpdateError < StandardError; end

def yo_update_api_key
	r = @conf['yo_update.api_key']
	if not r or r.empty?
		return nil
	end
	return r
end

def yo_update_access_api(req)
	if @conf['proxy']
		proxy_uri = URI("http://" + @conf['proxy'])
		proxy_addr = proxy_uri.host
		proxy_port = proxy_uri.port
	else
		proxy_addr = nil
		proxy_port = nil
	end
	begin
		timeout(YO_UPDATE_TIMEOUT) do
			return Net::HTTP.start(req.uri.host, req.uri.port, proxy_addr, proxt_port){|http|
				http.request(req)
			}
		end
	rescue Timeout::Error
		raise YoUpdateError, "Timeout accessing Yo API"
	rescue SocketError => e
		raise YoUpdateError, e.message
	end
end

def yo_update_send_yo(username = nil)
	api_key = yo_update_api_key
	unless api_key
		raise YoUpdateError, "Yo API Key is not set"
	end
	unless username
		req = Net::HTTP::Post.new(URI("http://api.justyo.co/yoall/"))
		req.set_form_data('api_token' => yo_update_api_key)
	else
		req = Net::HTTP::Post.new(URI("http://api.justyo.co/yo/"))
		req.set_form_data('api_token' => yo_update_api_key, 'username' => username)
	end
	res = yo_update_access_api(req)
	data = res.body
	unless data == '{"result": "OK"}'
		raise YoUpdateError, "error from Yo API: #{data}"
	end
	return data
end

def yo_update_subscribers_count
	api_key = yo_update_api_key
	unless api_key
		raise YoUpdateError, "Yo API Key is not set"
	end
	req = Net::HTTP::Get.new(
		URI("http://api.justyo.co/subscribers_count/?api_token=#{URI.escape(api_key)}")
	)
	res = yo_update_access_api(req)
	data = res.body
	begin
		r = JSON::parse(data)
		if r.has_key?('result')
			return r['result']
		else
			raise YoUpdateError, "Error from Yo API: #{data}"
		end
	rescue JSON::ParserError
		raise YoUpdateError, "Error from Yo API: #{data}"
	end
end

add_conf_proc('yo_update', 'Yo! with update' ) do
	test_result = ''
   if @mode == 'saveconf' then
      @conf['yo_update.api_key'] = @cgi.params['yo_update.api_key'][0]
      @conf['yo_update.username'] = @cgi.params['yo_update.username'][0]
      @conf['yo_update.send_on_update'] = (@cgi.params['yo_update.send_on_update'][0] == 't')
      @conf['yo_update.send_on_comment'] = (@cgi.params['yo_update.send_on_comment'][0] == 't')
		test_username = @cgi.params['yo_update.test'][0]
		if test_username and not test_username.empty?
			begin
				result = yo_update_send_yo(test_username)
			rescue YoUpdateError => e
				result = e.message
			end
			test_result = "- Sent to <tt>#{h test_username}</tt>: <tt>#{h result}</tt>"
		end
	end
	unless @conf.has_key?('yo_update.send_on_update')
		@conf['yo_update.send_on_update'] = true
   end
	begin
		n_subscribers = yo_update_subscribers_count
	rescue YoUpdateError => e
		n_subscribers = e.message
	end
   
   <<-HTML
   <h3 class="subtitle">API key</h3>
   <p><input name="yo_update.api_key" value="#{h @conf['yo_update.api_key']}" size="70"></p>
   <h3 class="subtitle">Username</h3>
   <p><input name="yo_update.username" value="#{h @conf['yo_update.username']}" size="70"></p>
   <h3 class="subtitle">Send Yo!</h3>
	<ul>
	#{%w(send_on_update send_on_comment).map{|action|
		checked = @conf["yo_update.#{action}"] ? ' checked' : ''
		label = action
		%Q|<li><label for="#{action}"><input name="yo_update.#{action}" value="t" type="checkbox"#{checked}>#{label}</label>|
	}.join("\n")}
	</ul>
   <p>Test sending Yo! to <input name="yo_update.test" value="" size="10">#{test_result}</p>
   <h3 class="subtitle">Current Subscribers</h3>
	<p>#{h n_subscribers}</p>
   HTML
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: ts=3 sw=3
