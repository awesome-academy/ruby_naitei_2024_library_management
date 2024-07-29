module UsersHelper
  def gender_options_for_select
    User.genders.map{|key, _| [key.capitalize, key]}
  end
end
