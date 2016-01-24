
require './lib/certificate_generator'

class Certificate
  include CertificateGenerator
  include DataMapper::Resource

  property :id, Serial
  property :identifier, Text
  property :created_at, DateTime
  property :certificate_key, Text
  property :image_key, Text

  belongs_to :delivery
  belongs_to :student
  
  
  before :save do
    student_name = self.student.full_name
    course_name = self.delivery.course.title
    generated_at = self.created_at.to_s
    identifier = Digest::SHA256.hexdigest("#{student_name} - #{course_name} - #{generated_at}")
    self.identifier = identifier
    self.save!
  end

   before :destroy do
    s3 = Aws::S3::Resource.new(region: ENV['AWS_REGION'])
    bucket = s3.bucket(ENV['S3_BUCKET'])

    certificate_key = bucket.object(self.certificate_key)
    image_key = bucket.object(self.image_key)

    certificate_key.delete
    image_key.delete
   end
  
    after :create do
      CertificateGenerator.generate(self)
    end
  
end