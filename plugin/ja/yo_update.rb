# -*- coding: utf-8 -*-
#
# yo_update.rb - Japanese resourc
#
# Copyright (C) 2014, zunda <zundan at gmail.com>
#
# Permission is granted for use, copying, modification,
# distribution, and distribution of modified versions of this
# work under the terms of GPL version 2 or later.
#

def yo_update_conf_label
	'Send Yo with updates'
end

def yo_update_conf_html(conf, test_result)
	action_label = {
		'send_on_update' => '日記が追加された時',
		'send_on_comment' => 'ツッコミされた時',
	}
	<<-HTML
	<h3 class="subtitle">API key</h3>
	<p><input name="yo_update.api_key" value="#{h conf['yo_update.api_key']}" size="40"></p>
	<h3 class="subtitle">Username</h3>
	<p><input name="yo_update.username" value="#{h conf['yo_update.username']}" size="40"></p>
	<h3 class="subtitle">Send Yo</h3>
	<ul>
	#{%w(send_on_update send_on_comment).map{|action|
		checked = conf["yo_update.#{action}"] ? ' checked' : ''
		%Q|<li><label for="yo_update.#{action}"><input id="yo_update.#{action}" name="yo_update.#{action}" value="t" type="checkbox"#{checked}>#{action_label[action]}</label>|
	}.join("\n\t")}
	</ul>
	<p>Test sending Yo! to <input name="yo_update.test" value="" size="10">#{test_result}</p>
	<h3 class="subtitle">Current Subscribers</h3>
	<p>#{h n_subscribers}</p>
	<h3 class="subtitle">Yo button</h3>
	<p>Add the following to somewhere or your diary.</p>
	<pre>&lt;div id=&quot;yo-button&quot;&gt;&lt;/div&gt;</pre>
	<h3 class="subtitle">Howto</h3>
	<ol>
	<li>Sign in with your personal Yo account at <a href="http://dev.justyo.co/">http://dev.justyo.co/</a>
	<li>Follow the instructions to obtain new API account.
		Please leave the Callback URL blank.
	<li>Copy the API key and API username above.
	</ol>
	HTML
end
