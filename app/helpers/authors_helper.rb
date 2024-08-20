module AuthorsHelper
  def gender_options_for_author_select
    Author.genders.map{|key, value| [key.humanize, value]}
  end
end
