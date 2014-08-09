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
# https://dev.justyo.co
#

require 'uri'
require 'timeout'
require 'open-uri'
require 'json'

class YoUpdateError < StandardError; end

def yo_update_api_key
	r = @conf['yo_update.api_key']
	raise YoUpdateError, "Yo API Key is not set" if not r or r.empty?
	return r
end

# TODO: rescue timeout and other network errors
def yo_update_subscribers_count
	begin
		params = ["http://api.justyo.co/subscribers_count/?api_token=#{URI.escape(yo_update_api_key)}"]
		params << {:proxy => "http://#{@conf['proxy']}"} if @conf['proxy']
		data = nil
		open(*params) do |f|
			data = f.read
		end
		r = JSON::parse(data)
		if r.has_key?('result')
			return r['result']
		elsif r.has_key?('error')
			e = JSON::parse(r['error'])
			raise YoUpdateError, "error from Yo API: #{e['message']} (code:#{e['code']})"
		end
	rescue YoUpdateError => e
		return e.message
	end
end

add_conf_proc('yo_update', 'Yo! with update' ) do
   if @mode == 'saveconf' then
      @conf['yo_update.api_key'] = @cgi.params['yo_update.api_key'][0]
      @conf['yo_update.username'] = @cgi.params['yo_update.username'][0]
      @conf['yo_update.send_on_update'] = (@cgi.params['yo_update.send_on_update'][0] == 't')
      @conf['yo_update.send_on_comment'] = (@cgi.params['yo_update.send_on_comment'][0] == 't')
	elsif not @conf.has_key?('yo_update.send_on_update')
		@conf['yo_update.send_on_update'] = true
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
   <h3 class="subtitle">Current Subscribers</h3>
	<p>#{h yo_update_subscribers_count}</p>
   HTML
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: ts=3 sw=3
