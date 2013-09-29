# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html
Rails.application.routes.draw do
resources :mail_users
resources :projects do
	resources :mail_messages, :only => [:index, :show]  do
		member do # member ==> 'with id'
			get  'new_reply'
			post 'send_reply'
		end
		collection do # collection ==> 'without id'
			get  'new_mail'
			post 'send_mail'
		end
	end
end
end
