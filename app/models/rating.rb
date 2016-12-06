class Rating
  attr_reader :id, :body, :stars, :title, :user_id, :product_id, :created_at, :updated_at

  def initialize(data)
    @id = data[:id]
    @body = data[:body]
    @stars = data[:stars]
    @title = data[:title]
    @user_id = data[:user_id]
    @product_id = data[:product_id]
    @created_at = data[:created_at]
    @updated_at = data[:updated_at]
  end

  def user
    @user ||= User.find(user_id)
  end

  def editable?
    created_at > Time.now.utc - 900
  end

  def display_name
    User.find(user_id).display_name
  end

  def save
    response = Rating.conn.post do |req|
      req.url '/ratings'
      req.params['product_id'] = product_id
      req.params['user_id'] = user_id
      req.params['body'] = body
      req.params['title'] = title
      req.params['stars'] = stars
    end
    Rating.parse_raw_data(response)[:error] ? false : true
  end

  def update_attributes(updated)
    response = Rating.conn.put do |req|
      req.url "/ratings/#{id}"
      req.params['product_id'] = product_id
      req.params['user_id'] = user_id
      req.params['body'] = updated[:body] || body
      req.params['title'] = updated[:title] || title
      req.params['stars'] = updated[:stars] || stars
    end
    Rating.parse_raw_data(response)[:error] ? false : true
  end

  def self.find(id)
    response = conn.get("/ratings/#{id}")
    Rating.new(parse_raw_data(response))
  end

  def self.fetch_all_for(id)
    response = conn.get do |req|                           # GET http://sushi.com/search?page=2&limit=100
      req.url '/ratings'
      req.params['product_id'] = id[:product]
      req.params['user_id'] = id[:user]
    end
    parse_raw_data(response).map { |raw| Rating.new(raw) }
  end

  def self.parse_raw_data(response)
    raw_data = JSON.parse(response.body, symbolize_names: true)
  end

  def self.conn
    Faraday.new('http://localhost:2000')
  end
end
