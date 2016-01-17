class Delivery
  include DataMapper::Resource

  property :id, Serial
  property :start_date, Date

  belongs_to :course

end
