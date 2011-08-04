	get '/fb' do
		haml :fbmain
	end

	get '/fb/login' do
		# generate a new oauth object with your app data and your callback url
		session['oauth'] = Koala::Facebook::OAuth.new(GTS.fbid, GTS.fbcode, GTS.url + 'fb/callback')
		# redirect to facebook to get your code
		redirect session['oauth'].url_for_oauth_code(:permissions => "publish_stream,offline_access")
	end

	get '/fb/logout' do
    session['oauth'] = nil
    session['access_token'] = nil
		redirect '/'
	end
	
	#method to handle the redirect from facebook back to you
	get '/fb/callback' do
		#get the access token from facebook with your code
		session['access_token'] = session['oauth'].get_access_token(params[:code])
		redirect '/fb'
	end
