# app.rb
require 'sinatra'
require 'json'
require 'byebug'
require_relative 'post'

# create data post
post '/posts' do
  begin
    request_body = JSON.parse(request.body.read)
    post = Post.create(title: request_body["title"], content: request_body["content"])

    content_type :json
    status 201
    return { post_id: post.id, message: 'success' }.to_json
  rescue => e
    content_type :json
    status 500
    return { error: e.message }.to_json
  end
end

# server errors simulations
post '/simulation_server_problems' do
  status 503

  content_type :json
  return { error: 'The server is having problems.' }.to_json
end

# open terminal
# cd your_project
# bundle install
# bundle exec ruby app.rb
# 1. success scenario
# curl --location 'http://localhost:4567/posts' \
# --header 'Content-Type: application/json' \
# --data '{
#     "title": "Post 1",
#     "content": "Content 1"
# }'
# 2. failed scenario
# curl --location 'http://localhost:4567/simulation_server_problems' \
# --header 'Content-Type: application/json' \
# --data '{
#     "title": "Post 1",
#     "content": "Content 1"
# }'