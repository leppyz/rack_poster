require './lib/router.rb'
use Rack::CommonLogger
use Rack::ShowExceptions
use Rack::Lint
use Rack::Static, 
  :urls => ["/media/images", "/media/js", "/media/css"],
  :root => "public"
class MyApp
	def self.call(env)
		new(env).response
	end
	def initialize(env)
		@request=Rack::Request.new(env)
	end
	def response()
		# env has request/response information
		@path= @request.path
		@req_method=@request.request_method
		@parameters=@request.params
		route(@path,@req_method,@parameters)
		
		Rack::Response.new(@responce)
		#[200, {'Content-Type' => 'text/html'}, [@responce]]
	end
	def route(path,req_method,parameters)
		@responce=""
		@controller_list=get_controllers_list
		controller,action,id=url_parser(path)
		case req_method
			when 'GET'
				if(controller==nil)
					@responce="root"
				else 
					if(action==nil)
						@responce=als_load(parameters,controller)
					else
						if(id==nil)
							@responce=als_load(parameters,controller,action,nil)
						else
							@responce=als_load(parameters,controller,action,id)
						end
					end
				end
			when 'POST'
				@responce="POST"
				@controller_list=get_controllers_list
				controller,action,id=url_parser(path)
				als_load(parameters,controller,action,id)
			when 'PUT'

			when 'PATCH'
			when 'DELETE'
			else
				@responce+=req_method
		end
		# @responce=path.scan('/\w*/').first.last+req_method;
	end
	def url_parser(url)
		case url
			when  /^\/$/

			when /^\/(\w*)(\/)?$/
				controller="#{$1}"
				if @controller_list.include? controller
					return [controller,nil,nil]
				else
					return [nil,nil,nil]
				end
			when /^\/(\w+)(\/)?(\w+)(\/)?$/
				controller="#{$1}"
				action="#{$3}"
				if @controller_list.include? controller
					return [controller,action,nil]
				else
					return [nil,nil,nil]
				end
			when /^\/\w*(\/)?\d*(\/)?\w*(\/)?$/
				controller="#{$1}"
				action="#{$3}"
				id="{$2}"
				if @controller_list.include? controller
					return [controller,action,id]
				else
					return [nil,nil,nil]
				end
			end
	end
	def als_load(params,controller,action="index",id=nil)
		controller_file="./app/controller/"+controller+"_controller.rb"
		load controller_file
		class_name=controller.capitalize+"Controller"
		@responce+=class_name;
		ob=class_name.constantize.new params
		ob.send(action)
		#@responce=" Action=#{action}"
	end
	def get_controllers_list
		@controller_list=[]
		@list= Dir['./app/controller/**.rb']
		@list.each { |controller|
			@controller_list.push(controller[/\w*\.rb/,0].sub(".rb","").sub("_controller",""))
		}
		return @controller_list
	end
end
run MyApp
