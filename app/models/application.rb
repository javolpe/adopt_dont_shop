class Application < ApplicationRecord 
  has_many :pet_applications
  has_many :pets, through: :pet_applications
  
  after_initialize :default, unless: :persisted?

  def default 
    self.status = "In Progress"
    self.description = "Please enter description"
  end

  def match_pets(name)
    if name 
      Pet.where("lower(name) LIKE ?", "%#{name.downcase}%")
    end
  end

  def pets_on_app(id)
    # Application.pets.where("application_id = #{id}")
    pets_apps = PetApplication.where("application_id = #{id}")
    pets = pets_apps.map{|pet| Pet.find(pet.pet_id)}
  end 

  def change_pet_status(commit, pet_id, app_id)
    pet_app = PetApplication.where(pet_id: pet_id).where(application_id: app_id).first
    if commit == "Approve"
      pet_app.update!(status: "Approved")  
    else commit == "Rejected"
      pet_app.update!(status: "Rejected")
    end
  end

  def change_status(app_id)
    all_records = PetApplication.where(application_id: app_id).select(:status)
    statuses = all_records.map{|rec| rec.status}.uniq
    if statuses.count == 1 && statuses[0] == "Approved"
      app = Application.find(app_id)
      app.update!(status: "Approved")
    else !statuses.any?{|s| s == "In progress"}
      app = Application.find(app_id)
      app.update!(status: "Rejected")
    end
  end
end