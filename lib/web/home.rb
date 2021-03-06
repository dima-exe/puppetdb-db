require 'slim'

module App
  class Home < App::Web
    get '/' do
      redirect '/ui'
    end

    get '/ui' do
      slim :index
    end

    get '/ui/*' do
      slim :index
    end

    get '/tests' do
      slim :tests
    end
  end
end
